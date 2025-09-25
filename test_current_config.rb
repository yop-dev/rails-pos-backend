#!/usr/bin/env ruby

require_relative 'config/environment'

puts "=== Current Email Configuration Test ==="
puts "Environment: #{Rails.env}"

# Check ActionMailer configuration
puts "\n🔍 ActionMailer Configuration:"
puts "  - Delivery method: #{Rails.application.config.action_mailer.delivery_method}"
puts "  - Perform deliveries: #{Rails.application.config.action_mailer.perform_deliveries}"

# Check ApplicationMailer
puts "\n🔍 ApplicationMailer:"
puts "  - Default from: #{ApplicationMailer.default[:from].call}"

# Test use_resend? method
app_mailer = ApplicationMailer.new
puts "  - Use Resend?: #{app_mailer.send(:use_resend?)}"

# Check environment variables
puts "\n🔍 Environment Variables:"
puts "  - RESEND_API_KEY: #{ENV['RESEND_API_KEY'] ? 'SET' : 'NOT SET'}"
puts "  - GMAIL_USERNAME: #{ENV['GMAIL_USERNAME'] ? 'SET' : 'NOT SET'}"

# Test OrderMailer with an existing order
puts "\n🧪 Testing OrderMailer..."

order = Order.first
if order
  puts "  - Found Order ##{order.id} (#{order.reference})"
  puts "  - Customer: #{order.customer.email}"
  
  # Create the email object but don't send it yet
  email = OrderMailer.order_placed(order)
  puts "  - Email created successfully"
  puts "  - Subject: #{email.subject}"
  puts "  - From: #{email.from}"
  puts "  - To: #{email.to}"
  
  puts "\n⚠️  Ready to send email. Should we send it? (y/n)"
  puts "   This will test the actual email delivery method."
  
else
  puts "  - No orders found in database"
  puts "  - Create an order through your frontend first"
end