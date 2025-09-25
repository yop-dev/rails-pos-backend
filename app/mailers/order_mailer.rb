class OrderMailer < ApplicationMailer
  def order_placed(order)
    @order = order
    @customer = order.customer
    @merchant = order.merchant
    @delivery_address = order.delivery_address
    @order_items = order.order_items.includes(:product)
    
    # Prepare formatted data for email template
    @customer_full_name = @customer.full_name
    @customer_email = @customer.email
    @customer_mobile = @customer.phone || "N/A"
    
    # Format delivery address according to specification
    @formatted_delivery_address = format_delivery_address(@delivery_address)
    
    # Get shipping and payment method labels
    @shipping_method = @order.shipping_method_label || "Not specified"
    @payment_method = @order.payment_method_label || "Not specified"
    
    # Prepare amounts for summary
    @subtotal_amount = @order.subtotal.formatted
    @shipping_fee_amount = @order.shipping_fee.formatted
    @convenience_fee_amount = @order.convenience_fee.formatted
    @grand_total_amount = @order.total.formatted

    # Use the enhanced mail_with_sender method for flexible from address
    mail_with_sender(
      merchant_email: @merchant.email,
      to: @customer.email,
      # Uncomment the line below to also send copy to merchant
      # bcc: @merchant.email,
      subject: "Order Placed Successfully - Order Reference Number: #{@order.reference}"
    )
  end
  
  private
  
  def format_delivery_address(address)
    return "Not specified" unless address
    
    # Format: [Unit, Floor, Building Name, Street, Baranggay, City, Province]
    address_parts = []
    address_parts << address.unit_floor_building if address.unit_floor_building.present?
    address_parts << address.street if address.street.present?
    address_parts << address.barangay if address.barangay.present?
    address_parts << address.city if address.city.present?
    address_parts << address.province if address.province.present?
    
    address_parts.join(", ")
  end
end
