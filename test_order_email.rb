#!/usr/bin/env ruby

require_relative 'config/environment'

puts "=== Testing OrderMailer with Resend ==="

# Find an order to test with
order = Order.first

if order
  puts "📋 Using Order ##{order.id} (#{order.reference})"
  puts "   Customer: #{order.customer.email}"
  
  begin
    puts "\n📧 Sending order confirmation email..."
    
    # Send the email using OrderMailer
    OrderMailer.order_placed(order).deliver_now
    
    puts "✅ Email sent successfully!"
    puts "📬 Check your email inbox: #{order.customer.email}"
    puts "   Should come from: Rails POS <noreply@yopn8n.cfd>"
    puts "   Subject: Order Placed Successfully - Order Reference Number: #{order.reference}"
    
  rescue => e
    puts "❌ Error sending email: #{e.message}"
    puts "   Error class: #{e.class}"
    puts "   Backtrace: #{e.backtrace.first(3).join('\n   ')}"
  end
  
else
  puts "❌ No orders found in database"
  puts "   Create an order through your frontend first"
end