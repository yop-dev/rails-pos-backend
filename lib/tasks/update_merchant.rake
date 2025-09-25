namespace :merchant do
  desc "Update merchant information"
  task update: :environment do
    puts "Updating merchant information..."

    # Find the existing merchant by old email
    old_merchant = Merchant.find_by(email: "merchant@example.com")

    if old_merchant
      # Update the merchant information
      old_merchant.update!(
        name: "Genie Orders",
        email: "desilvajoner95@gmail.com"
      )
      puts "✅ Merchant updated successfully!"
      puts "   Name: #{old_merchant.name}"
      puts "   Email: #{old_merchant.email}"
    else
      # If old merchant doesn't exist, try to find or create with new email
      merchant = Merchant.find_or_create_by!(email: "desilvajoner95@gmail.com") do |m|
        m.name = "Genie Orders"
        m.phone = "09171234567"
        m.address = "123 Main Street, Quezon City, Metro Manila"
      end
      puts "✅ Merchant created/found with new email!"
      puts "   Name: #{merchant.name}"
      puts "   Email: #{merchant.email}"
    end

    puts "Merchant update completed!"
  end
end