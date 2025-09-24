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

# Create a sample customer
customer = merchant.customers.find_or_create_by!(email: "john@example.com") do |c|
  c.first_name = "John"
  c.last_name = "Doe"
  c.phone = "09171234567"
end

# Create a sample address for the customer
address = customer.addresses.find_or_create_by!(street: "456 Sample Street") do |a|
  a.unit_floor_building = "Unit 2B"
  a.barangay = "Barangay Santo Domingo"
  a.city = "Quezon City"
  a.province = "Metro Manila"
  a.postal_code = "1114"
  a.landmark = "Near SM North EDSA"
end

puts "Created customer: #{customer.full_name}"
puts "Created address: #{address.display_address}"

puts "Sample data created successfully!"
puts "\nYou can now test the GraphQL API at http://localhost:3000/graphiql"
puts "Sample merchant: #{merchant.name} (#{merchant.email})"
puts "Sample customer: #{customer.full_name} (#{customer.email})"
puts "Products created: #{merchant.products.count}"
puts "Categories created: #{merchant.product_categories.count}"
