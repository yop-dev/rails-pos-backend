class PaymentLinkService
  def initialize(order)
    @order = order
  end

  def build_link
    return nil unless requires_payment_link?

    # This would integrate with a real payment gateway like PayMongo, Stripe, etc.
    # For development/assessment purposes, we'll return a mock payment link
    base_url = Rails.application.config.payment_gateway_url || "https://payments.example.com"
    
    "#{base_url}/pay?order_id=#{@order.id}&amount=#{@order.total_cents}&currency=#{@order.customer.merchant.currency || 'PHP'}&reference=#{@order.reference}"
  end

  private

  def requires_payment_link?
    @order.online? && payment_method_requires_link?
  end

  def payment_method_requires_link?
    # Online payment methods that require a payment link
    online_payment_methods = %w[ONLINE_CARD ONLINE_BANKING GCASH PAYMAYA PAYPAL]
    online_payment_methods.include?(@order.payment_method_code)
  end
end