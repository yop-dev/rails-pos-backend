class VoucherService
  def initialize(order, voucher_code)
    @order = order
    @voucher_code = voucher_code&.upcase&.strip
  end

  def compute_discount
    return 0 unless @voucher_code.present?
    
    voucher = find_voucher(@voucher_code)
    return 0 unless voucher && valid_voucher?(voucher)
    
    calculate_discount_amount(voucher)
  end

  private

  def find_voucher(code)
    # In a real application, this would query a vouchers/coupons table
    # For assessment purposes, we'll use hardcoded vouchers
    vouchers = {
      "WELCOME10" => {
        type: "percentage",
        value: 10, # 10%
        minimum_order: 50000, # ₱500.00
        maximum_discount: 20000 # ₱200.00 max discount
      },
      "FIRSTORDER" => {
        type: "fixed",
        value: 10000, # ₱100.00
        minimum_order: 30000 # ₱300.00
      },
      "FREESHIP" => {
        type: "shipping",
        value: 0, # Free shipping
        minimum_order: 100000 # ₱1000.00
      },
      "SAVE50" => {
        type: "fixed",
        value: 5000, # ₱50.00
        minimum_order: 0 # No minimum
      }
    }
    
    vouchers[code]
  end

  def valid_voucher?(voucher)
    # Check if order meets minimum requirements
    @order.subtotal_cents >= voucher[:minimum_order]
  end

  def calculate_discount_amount(voucher)
    case voucher[:type]
    when "percentage"
      discount = (@order.subtotal_cents * voucher[:value] / 100.0).round
      # Apply maximum discount limit if specified
      if voucher[:maximum_discount]
        [discount, voucher[:maximum_discount]].min
      else
        discount
      end
    when "fixed"
      # Fixed amount discount, but not more than subtotal
      [voucher[:value], @order.subtotal_cents].min
    when "shipping"
      # Free shipping - return the shipping fee as discount
      @order.shipping_fee_cents
    else
      0
    end
  end
end