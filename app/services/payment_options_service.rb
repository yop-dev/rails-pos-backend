class PaymentOptionsService
  def available_options
    # In a real application, this would be configured in admin settings
    # For assessment purposes, we'll return a fixed set of payment options
    
    [
      {
        code: "CASH",
        label: "Cash Payment",
        convenience_fee_cents: 0
      },
      {
        code: "ONLINE_CARD",
        label: "Credit/Debit Card",
        convenience_fee_cents: 3000 # ₱30.00 convenience fee
      },
      {
        code: "ONLINE_BANKING",
        label: "Online Banking",
        convenience_fee_cents: 1500 # ₱15.00 convenience fee
      },
      {
        code: "GCASH",
        label: "GCash",
        convenience_fee_cents: 1000 # ₱10.00 convenience fee
      },
      {
        code: "PAYMAYA",
        label: "PayMaya",
        convenience_fee_cents: 1000 # ₱10.00 convenience fee
      },
      {
        code: "PAYPAL",
        label: "PayPal",
        convenience_fee_cents: 5000 # ₱50.00 convenience fee
      },
      {
        code: "COD",
        label: "Cash on Delivery",
        convenience_fee_cents: 2000 # ₱20.00 COD fee
      }
    ]
  end

  def find_by_code(code)
    available_options.find { |option| option[:code] == code }
  end

  def convenience_fee_for(code)
    option = find_by_code(code)
    option ? option[:convenience_fee_cents] : 0
  end
end