module Mutations
  class CreateOrder < Types::BaseMutation
    description "Create a new order"

    argument :input, Types::OrderInput, required: true

    field :order, Types::OrderType, null: true
    field :errors, [Types::ErrorType], null: false

    def resolve(input:)
      merchant = current_merchant
      
      # Find or create customer
      customer = find_or_create_customer(merchant, input)
      return customer if customer.is_a?(Hash) && customer[:errors] # Error response

      # Create delivery address if provided
      delivery_address = nil
      if input.delivery_address
        delivery_address = create_delivery_address(customer, input.delivery_address)
      end

      # Validate products and create order items data
      order_items_data = validate_and_prepare_items(merchant, input.items)
      return order_items_data if order_items_data.is_a?(Hash) && order_items_data[:errors] # Error response

      # Validate payment method compatibility with product types
      payment_validation = validate_payment_method_for_products(order_items_data, input.payment_method_code)
      return payment_validation if payment_validation.is_a?(Hash) && payment_validation[:errors] # Error response

      # Get payment method info
      payment_info = get_payment_info(input.payment_method_code)
      
      # Get shipping method info for online orders
      shipping_info = nil
      Rails.logger.debug "Input source: #{input.source}, shipping_method_code: #{input.shipping_method_code.inspect}"
      if input.source == 'online' && input.shipping_method_code
        shipping_info = get_shipping_info(input.shipping_method_code, input.delivery_address, input.items)
        Rails.logger.debug "Retrieved shipping_info: #{shipping_info.inspect}"
      end
      
      # Create order
      order = merchant.orders.build
      order.customer = customer
      order.delivery_address = delivery_address
      order.source = input.source
      
      # Set payment method info
      order.payment_method_code = input.payment_method_code
      order.payment_method_label = payment_info ? payment_info[:label] : nil
      order.convenience_fee_cents = payment_info ? payment_info[:convenience_fee_cents] : 0
      
      # Set shipping method info for online orders
      if shipping_info
        order.shipping_method_code = shipping_info[:code]
        order.shipping_method_label = shipping_info[:label]
        order.shipping_fee_cents = shipping_info[:fee_cents]
      else
        order.shipping_method_code = nil
        order.shipping_method_label = nil
        order.shipping_fee_cents = 0
      end
      
      # Initialize other required fields
      order.subtotal_cents = 0
      order.total_cents = 0
      
      # Debug logging
      Rails.logger.debug "Order fees - Convenience: #{order.convenience_fee_cents}, Shipping: #{order.shipping_fee_cents}"
      
      # order.notes = input.notes  # Notes not supported in Order model
      
      # Skip both callback and validation initially since we don't have items yet
      order.skip_calculate_totals = true
      order.skip_total_validation = true
      
      # Manually generate reference since we're skipping callbacks
      if order.reference.blank?
        loop do
          candidate = "ORD-#{Date.current.strftime('%Y%m%d')}-#{SecureRandom.hex(3).upcase}"
          break order.reference = candidate unless Order.exists?(reference: candidate)
        end
      end
      
      ActiveRecord::Base.transaction do
        if order.save
          # Create order items
          order_items_data.each do |item_data|
            order_item = order.order_items.build(
              product: item_data[:product],
              quantity: item_data[:quantity],
              unit_price_cents: item_data[:product].price_cents
            )
            # Explicitly set the snapshot and total to ensure callbacks work
            order_item.product_name_snapshot = item_data[:product].name
            order_item.total_price_cents = order_item.unit_price_cents * order_item.quantity
            order_item.save!
          end

          # Now calculate totals manually since we have all the data
          order.reload
          
          # Calculate subtotal from order items
          calculated_subtotal = order.order_items.sum(:total_price_cents)
          order.subtotal_cents = calculated_subtotal
          
          # Keep the fees we set earlier
          convenience_fee = order.convenience_fee_cents || 0
          shipping_fee = order.shipping_fee_cents || 0
          # Calculate total: subtotal + shipping + convenience
          calculated_total = calculated_subtotal + shipping_fee + convenience_fee
          order.total_cents = calculated_total
          
          # Debug logging
          Rails.logger.debug "Final calculation - Subtotal: #{calculated_subtotal}, Shipping: #{shipping_fee}, Convenience: #{convenience_fee}, Total: #{calculated_total}"
          Rails.logger.debug "Order state before save - subtotal_cents: #{order.subtotal_cents}, shipping_fee_cents: #{order.shipping_fee_cents}, convenience_fee_cents: #{order.convenience_fee_cents}, total_cents: #{order.total_cents}"
          Rails.logger.debug "Final order method labels - payment_method_label: #{order.payment_method_label.inspect}, shipping_method_label: #{order.shipping_method_label.inspect}"
          
          # Skip callback but allow validation (total validation is already skipped)
          order.skip_calculate_totals = true
          order.skip_total_validation = true
          order.save!
          
          # Manually trigger email notification since we skipped callbacks
          begin
            OrderMailer.order_placed(order).deliver_later
            Rails.logger.info "Order confirmation email queued for customer: #{order.customer.email}"
          rescue => e
            Rails.logger.error "Failed to send order confirmation email: #{e.message}"
          end

          {
            order: order,
            errors: []
          }
        else
          {
            order: nil,
            errors: format_errors(order.errors)
          }
        end
      end
    rescue => e
      {
        order: nil,
        errors: [{ message: "Failed to create order: #{e.message}" }]
      }
    end

    private

    def current_merchant
      context[:current_merchant] || Merchant.first
    end

    def find_or_create_customer(merchant, input)
      if input.customer_id
        # Find existing customer by ID
        customer = merchant.customers.find_by(id: input.customer_id)
        unless customer
          return {
            order: nil,
            errors: [{ message: "Customer not found" }]
          }
        end
        customer
      elsif input.customer
        # Find by email or create new customer
        customer_input = input.customer
        customer = merchant.customers.find_by(email: customer_input.email)
        if customer
          # Update customer info
          customer.first_name = customer_input.first_name
          customer.last_name = customer_input.last_name
          customer.phone = customer_input.phone if customer_input.phone
          customer.save!
        else
          # Create new customer
          customer = merchant.customers.create!(
            email: customer_input.email,
            first_name: customer_input.first_name,
            last_name: customer_input.last_name,
            phone: customer_input.phone
          )
        end
        customer
      else
        return {
          order: nil,
          errors: [{ message: "Either customer or customerId must be provided" }]
        }
      end
    end

    def create_delivery_address(customer, address_input)
      # Create an actual Address record
      customer.addresses.create!(
        street: address_input.line1,
        unit_floor_building: address_input.line2,
        city: address_input.city,
        province: address_input.state,
        postal_code: address_input.postal_code,
        barangay: address_input.barangay || "Unknown" # Use barangay from input or default
      )
    end

    def validate_and_prepare_items(merchant, items_input)
      items_data = []
      
      items_input.each_with_index do |item_input, index|
        product = merchant.products.active.find_by(id: item_input.product_id)
        
        unless product
          return {
            order: nil,
            payment_link: nil,
            errors: [{ message: "Product not found or inactive", path: ["items", index.to_s, "product_id"] }]
          }
        end

        unless item_input.quantity > 0
          return {
            order: nil,
            payment_link: nil,
            errors: [{ message: "Quantity must be greater than 0", path: ["items", index.to_s, "quantity"] }]
          }
        end

        items_data << {
          product: product,
          quantity: item_input.quantity
        }
      end

      items_data
    end

    def validate_payment_method_for_products(items_data, payment_method_code)
      # Check if any digital products are being ordered with cash on delivery
      if payment_method_code == 'cash'
        digital_products = items_data.select { |item| item[:product].digital? }
        
        if digital_products.any?
          digital_product_names = digital_products.map { |item| item[:product].name }.join(", ")
          return {
            order: nil,
            errors: [{ 
              message: "Cash on delivery is not available for digital products: #{digital_product_names}", 
              field: "payment_method_code" 
            }]
          }
        end
      end
      
      # Validation passed
      nil
    end

    def get_shipping_info(shipping_method_code, delivery_input, items_input)
      return nil unless shipping_method_code

      # Simple shipping method mapping based on frontend codes
      # This matches the shipping methods used in the frontend cart store
      shipping_methods = {
        'standard' => {
          code: 'standard',
          label: 'Standard Delivery',
          fee_cents: 500 # ₱5.00
        },
        'express' => {
          code: 'express', 
          label: 'Express Delivery',
          fee_cents: 1500 # ₱15.00
        },
        'same_day' => {
          code: 'same_day',
          label: 'Same Day Delivery', 
          fee_cents: 3000 # ₱30.00
        },
        'pickup' => {
          code: 'pickup',
          label: 'Store Pickup',
          fee_cents: 0 # Free
        }
      }
      
      shipping_methods[shipping_method_code]
    end

    def get_payment_info(payment_method_code)
      return nil unless payment_method_code

      # Simple payment method mapping based on frontend codes  
      # This matches the payment methods used in the frontend cart store
      payment_methods = {
        'cash' => {
          code: 'cash',
          label: 'Cash on Delivery',
          convenience_fee_cents: 0
        },
        'card' => {
          code: 'card',
          label: 'Credit/Debit Card',
          convenience_fee_cents: 100 # ₱1.00
        },
        'gcash' => {
          code: 'gcash',
          label: 'GCash',
          convenience_fee_cents: 50 # ₱0.50
        },
        'paymaya' => {
          code: 'paymaya',
          label: 'PayMaya',
          convenience_fee_cents: 50 # ₱0.50
        },
        'bank_transfer' => {
          code: 'bank_transfer',
          label: 'Bank Transfer',
          convenience_fee_cents: 0
        }
      }
      
      payment_methods[payment_method_code]
    end

    def requires_payment_link?(payment_method_code)
      online_payment_methods = %w[ONLINE_CARD ONLINE_BANKING GCASH PAYMAYA PAYPAL]
      online_payment_methods.include?(payment_method_code)
    end

    def format_errors(active_record_errors)
      active_record_errors.full_messages.map do |message|
        {
          message: message
        }
      end
    end
  end
end