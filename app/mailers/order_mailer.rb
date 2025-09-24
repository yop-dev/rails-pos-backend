class OrderMailer < ApplicationMailer
  def order_placed(order)
    @order = order
    @customer = order.customer
    @merchant = order.merchant
    @delivery_address = order.delivery_address
    @order_items = order.order_items.includes(:product)

    mail(
      to: @customer.email,
      subject: "Order Confirmation - #{@order.reference}",
      from: @merchant.email || "noreply@#{Rails.application.config.action_mailer.default_url_options[:host]}"
    )
  end
end