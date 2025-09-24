# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Creating sample data..."

# Create a demo merchant
merchant = Merchant.find_or_create_by!(email: "merchant@example.com") do |m|
  m.name = "Demo Coffee Shop"
  m.phone = "09171234567"
  m.address = "123 Main Street, Quezon City, Metro Manila"
end

puts "Created merchant: #{merchant.name}"

# Create product categories
categories = [
  { name: "Coffee & Tea", position: 1 },
  { name: "Pastries", position: 2 },
  { name: "Merchandise", position: 3 },
  { name: "Digital Products", position: 4 }
]

categories.each do |cat_attrs|
  category = merchant.product_categories.find_or_create_by!(name: cat_attrs[:name]) do |c|
    c.position = cat_attrs[:position]
  end
  puts "Created category: #{category.name}"
end

# Create sample products
coffee_category = merchant.product_categories.find_by(name: "Coffee & Tea")
pastry_category = merchant.product_categories.find_by(name: "Pastries")
merch_category = merchant.product_categories.find_by(name: "Merchandise")
digital_category = merchant.product_categories.find_by(name: "Digital Products")

products = [
  # Coffee & Tea
  { name: "House Blend Coffee", description: "Our signature coffee blend", category: coffee_category, price_cents: 15000, product_type: "physical" },
  { name: "Cappuccino", description: "Classic cappuccino with steamed milk", category: coffee_category, price_cents: 18000, product_type: "physical" },
  { name: "Green Tea Latte", description: "Matcha green tea with milk", category: coffee_category, price_cents: 20000, product_type: "physical" },
  { name: "Iced Americano", description: "Cold brew americano", category: coffee_category, price_cents: 16000, product_type: "physical" },
  
  # Pastries
  { name: "Chocolate Croissant", description: "Buttery croissant with chocolate filling", category: pastry_category, price_cents: 12000, product_type: "physical" },
  { name: "Blueberry Muffin", description: "Fresh blueberry muffin", category: pastry_category, price_cents: 10000, product_type: "physical" },
  { name: "Cheesecake Slice", description: "New York style cheesecake", category: pastry_category, price_cents: 25000, product_type: "physical" },
  
  # Merchandise
  { name: "Coffee Shop T-Shirt", description: "Official branded t-shirt", category: merch_category, price_cents: 80000, product_type: "physical" },
  { name: "Coffee Mug", description: "Ceramic coffee mug with logo", category: merch_category, price_cents: 35000, product_type: "physical" },
  
  # Digital Products
  { name: "Coffee Recipe eBook", description: "Digital recipe collection", category: digital_category, price_cents: 30000, product_type: "digital" },
  { name: "Barista Training Course", description: "Online barista certification", category: digital_category, price_cents: 150000, product_type: "digital" }
]

products.each do |prod_attrs|
  product = merchant.products.find_or_create_by!(name: prod_attrs[:name]) do |p|
    p.description = prod_attrs[:description]
    p.product_category = prod_attrs[:category]
    p.price_cents = prod_attrs[:price_cents]
    p.product_type = prod_attrs[:product_type]
    p.currency = "PHP"
  end
  puts "Created product: #{product.name} (#{product.price.formatted})"
end

# Create sample customers
customers_data = [
  {
    email: "john@example.com",
    first_name: "John",
    last_name: "Doe",
    phone: "09171234567",
    address: {
      street: "456 Sample Street",
      unit_floor_building: "Unit 2B",
      barangay: "Barangay Santo Domingo",
      city: "Quezon City",
      province: "Metro Manila",
      postal_code: "1114",
      landmark: "Near SM North EDSA"
    }
  },
  {
    email: "maria.santos@gmail.com",
    first_name: "Maria",
    last_name: "Santos",
    phone: "09181234567",
    address: {
      street: "789 Luna Street",
      unit_floor_building: "Apartment 3A",
      barangay: "Barangay San Antonio",
      city: "Makati City",
      province: "Metro Manila",
      postal_code: "1200",
      landmark: "Near Ayala Triangle"
    }
  },
  {
    email: "jose.rizal@email.com",
    first_name: "Jose",
    last_name: "Rizal",
    phone: "09191234567",
    address: {
      street: "101 Rizal Avenue",
      barangay: "Barangay Heroes",
      city: "Manila",
      province: "Metro Manila",
      postal_code: "1000",
      landmark: "Near Rizal Park"
    }
  },
  {
    email: "ana.cruz@yahoo.com",
    first_name: "Ana",
    last_name: "Cruz",
    phone: "09201234567",
    address: {
      street: "555 Del Pilar Street",
      unit_floor_building: "House 15",
      barangay: "Barangay Del Pilar",
      city: "Quezon City",
      province: "Metro Manila",
      postal_code: "1105",
      landmark: "Near UP Diliman"
    }
  },
  {
    email: "miguel.rodriguez@hotmail.com",
    first_name: "Miguel",
    last_name: "Rodriguez",
    phone: "09211234567",
    address: {
      street: "321 Bonifacio Street",
      barangay: "Barangay Poblacion",
      city: "Pasig City",
      province: "Metro Manila",
      postal_code: "1600",
      landmark: "Near Ortigas Center"
    }
  }
]

customers_data.each do |customer_data|
  customer = merchant.customers.find_or_create_by!(email: customer_data[:email]) do |c|
    c.first_name = customer_data[:first_name]
    c.last_name = customer_data[:last_name]
    c.phone = customer_data[:phone]
  end
  
  # Create address for the customer
  address_data = customer_data[:address]
  address = customer.addresses.find_or_create_by!(street: address_data[:street]) do |a|
    a.unit_floor_building = address_data[:unit_floor_building]
    a.barangay = address_data[:barangay]
    a.city = address_data[:city]
    a.province = address_data[:province]
    a.postal_code = address_data[:postal_code]
    a.landmark = address_data[:landmark]
  end
  
  puts "Created customer: #{customer.full_name} (#{customer.email})"
  puts "  Address: #{address.display_address}"
end

puts "Sample data created successfully!"
puts "\nYou can now test the GraphQL API at http://localhost:3000/graphiql"
puts "Sample merchant: #{merchant.name} (#{merchant.email})"
puts "Sample customers created: #{merchant.customers.count}"
puts "Products created: #{merchant.products.count}"
puts "Categories created: #{merchant.product_categories.count}"

puts "\nCustomer emails to test search:"
merchant.customers.each do |customer|
  puts "  - #{customer.email} (#{customer.full_name})"
end
