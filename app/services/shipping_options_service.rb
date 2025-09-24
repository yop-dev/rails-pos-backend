class ShippingOptionsService
  def initialize(delivery_address, items)
    @delivery_address = delivery_address
    @items = items
  end

  def available_options
    # In a real application, this would integrate with shipping providers
    # For assessment purposes, we'll return mock shipping options based on location
    
    base_options = [
      {
        code: "STANDARD_DELIVERY",
        label: "Standard Delivery (3-5 business days)",
        fee_cents: calculate_standard_fee
      },
      {
        code: "EXPRESS_DELIVERY",
        label: "Express Delivery (1-2 business days)",
        fee_cents: calculate_express_fee
      }
    ]

    # Add same-day delivery for Metro Manila
    if metro_manila_area?
      base_options << {
        code: "SAME_DAY_DELIVERY",
        label: "Same Day Delivery",
        fee_cents: calculate_same_day_fee
      }
    end

    # Free shipping for orders above threshold
    if qualifies_for_free_shipping?
      base_options.unshift({
        code: "FREE_SHIPPING",
        label: "Free Shipping (5-7 business days)",
        fee_cents: 0
      })
    end

    base_options
  end

  private

  def calculate_standard_fee
    base_fee = 10000 # ₱100.00 base fee
    base_fee += weight_surcharge
    base_fee += distance_surcharge
    base_fee
  end

  def calculate_express_fee
    calculate_standard_fee * 1.5
  end

  def calculate_same_day_fee
    calculate_standard_fee * 2
  end

  def weight_surcharge
    # Calculate based on estimated weight of items
    total_items = @items.sum { |item| item[:quantity] }
    return 0 if total_items <= 3
    
    (total_items - 3) * 2000 # ₱20.00 per additional item
  end

  def distance_surcharge
    # Calculate based on delivery location
    return 0 if metro_manila_area?
    return 5000 if luzon_area? # ₱50.00 surcharge
    return 15000 # ₱150.00 for Visayas/Mindanao
  end

  def qualifies_for_free_shipping?
    # Mock logic - would calculate actual total in real implementation
    @items.length >= 5 # Free shipping for 5+ items
  end

  def metro_manila_area?
    metro_manila_cities = [
      "Manila", "Quezon City", "Makati", "Pasig", "Taguig", "Mandaluyong",
      "Pasay", "Parañaque", "Las Piñas", "Muntinlupa", "Marikina", "Valenzuela",
      "Malabon", "Navotas", "Caloocan", "San Juan"
    ]
    
    metro_manila_cities.any? { |city| @delivery_address[:city].to_s.downcase.include?(city.downcase) }
  end

  def luzon_area?
    luzon_provinces = [
      "Bataan", "Bulacan", "Nueva Ecija", "Pampanga", "Tarlac", "Zambales",
      "Aurora", "Batangas", "Cavite", "Laguna", "Quezon", "Rizal"
    ]
    
    luzon_provinces.any? { |province| @delivery_address[:province].to_s.downcase.include?(province.downcase) }
  end
end