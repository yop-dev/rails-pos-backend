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

      # Create order
      order = merchant.orders.build
      order.customer = customer
      order.delivery_address = delivery_address
      order.source = input.source
      order.payment_method_code = input.payment_method_code
      # order.notes = input.notes  # Notes not supported in Order model
      
      # Ensure reference is generated if not set by callback
      if order.reference.blank?
        loop do
          candidate = "ORD-#{Date.current.strftime('%Y%m%d')}-#{SecureRandom.hex(3).upcase}"
          break order.reference = candidate unless Order.exists?(reference: candidate)
        end
      end
      
      # Calculate totals will be handled by the model callbacks
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

          # Recalculate totals after items are created
          order.reload
          order.save!

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
      # Create a simple address object (assuming Address model exists)
      # For now, let's create a simple hash structure
      {
        line1: address_input.line1,
        line2: address_input.line2,
        city: address_input.city,
        state: address_input.state,
        postal_code: address_input.postal_code,
        country: address_input.country
      }
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

    def get_shipping_info(shipping_method_code, delivery_input, items_input)
      return nil unless delivery_input && shipping_method_code

      options = ShippingOptionsService.new(delivery_input.to_h, items_input.map(&:to_h)).available_options
      option = options.find { |opt| opt[:code] == shipping_method_code }
      
      if option
        {
          code: option[:code],
          label: option[:label],
          fee_cents: option[:fee_cents]
        }
      else
        nil
      end
    end

    def get_payment_info(payment_method_code)
      return nil unless payment_method_code

      service = PaymentOptionsService.new
      option = service.find_by_code(payment_method_code)
      
      if option
        {
          code: option[:code],
          label: option[:label],
          convenience_fee_cents: option[:convenience_fee_cents]
        }
      else
        nil
      end
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