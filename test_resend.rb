#!/usr/bin/env ruby

# Resend Email Test Script
# This script tests the new Resend integration
# Run with: ruby test_resend.rb

require_relative 'config/environment'

puts "=== Resend Email Test ==="
puts "Environment: #{Rails.env}"
puts

# Test email address
TEST_EMAIL = 'desilvajoner95@gmail.com'

def test_environment_variables
  puts "🔍 Checking Resend Environment Variables:"
  
  resend_vars = [
    'RESEND_API_KEY',
    'RESEND_FROM_EMAIL',
    'RESEND_FROM_NAME'
  ]
  
  resend_vars.each do |var|
    value = ENV[var]
    if value.present?
      # Show partial value for security
      display_value = case var
      when 'RESEND_API_KEY'
        "#{value[0..10]}...#{value[-10..-1]}"
      else
        value
      end
      puts "  ✅ #{var}: #{display_value}"
    else
      puts "  ❌ #{var}: NOT SET"
    end
  end
  puts
end

def test_resend_service
  puts "🔍 Testing ResendService directly:"
  
  begin
    resend = ResendService.new
    
    result = resend.send_email(
      to: TEST_EMAIL,
      subject: 'Resend Service Test - Rails POS',
      html_content: '<h1>Success!</h1><p>This email was sent directly via ResendService from Rails POS development.</p>',
      text_content: 'Success! This email was sent directly via ResendService from Rails POS development.'
    )
    
    if result[:success]
      puts "  ✅ ResendService test successful!"
      puts "  📧 Check your inbox: #{TEST_EMAIL}"
    else
      puts "  ❌ ResendService failed: #{result[:error]}"
    end
  rescue => e
    puts "  ❌ ResendService error: #{e.message}"
  end
  puts
end

def test_actionmailer_config
  puts "🔍 ActionMailer Configuration:"
  puts "  - Delivery method: #{Rails.application.config.action_mailer.delivery_method}"
  puts "  - Perform deliveries: #{Rails.application.config.action_mailer.perform_deliveries}"
  puts "  - Raise delivery errors: #{Rails.application.config.action_mailer.raise_delivery_errors}"
  puts
end

def test_application_mailer
  puts "🔍 Testing ApplicationMailer integration:"
  
  begin
    # Create a simple test mailer
    test_mail = ActionMailer::Base.mail(
      from: 'Rails POS <noreply@yopn8n.cfd>',
      to: TEST_EMAIL,
      subject: 'ApplicationMailer + Resend Integration Test',
      body: 'This email was sent via ApplicationMailer using Resend API integration.'
    )
    
    # This won't actually send because we need to use our custom method
    puts "  ℹ️  ActionMailer mail object created successfully"
    
    # Test our custom method
    class TestMailer < ApplicationMailer
      def test_email(to_email)
        mail_with_sender(
          to: to_email,
          subject: 'Rails POS - ApplicationMailer + Resend Test',
          template: 'test_email'  # We'll create a simple template
        )
      end
    end
    
    # We need a simple template for this test
    puts "  📧 Testing with custom mailer method..."
    
  rescue => e
    puts "  ❌ ApplicationMailer test error: #{e.message}"
  end
  puts
end

def test_order_mailer
  puts "🔍 Testing OrderMailer (Full Integration):"
  
  begin
    # Try to find an existing order
    order = Order.first
    
    if order.nil?
      puts "  ⚠️  No orders found in database"
      puts "     Create an order through your application to test OrderMailer"
    else
      puts "  📋 Using Order ##{order.id} (Reference: #{order.reference})"
      
      # Test the actual OrderMailer
      email = OrderMailer.order_placed(order)
      
      # This should now use Resend via our ApplicationMailer integration
      # Note: We're not calling deliver_now yet in case there's an issue
      puts "  ✅ OrderMailer email object created successfully!"
      puts "  📧 Would send to: #{order.customer.email}"
      puts "  ⚠️  Uncomment the line below to actually send the email"
      # email.deliver_now
    end
  rescue => e
    puts "  ❌ OrderMailer test failed: #{e.message}"
  end
  puts
end

def main
  puts "Testing Resend integration with email to: #{TEST_EMAIL}"
  puts
  
  test_environment_variables
  test_actionmailer_config
  test_resend_service
  test_application_mailer
  test_order_mailer
  
  puts "=== Test Summary ==="
  puts "✅ If ResendService test succeeded, your integration is working!"
  puts "📧 Check your email inbox (including spam folder)"
  puts "🚀 Ready to deploy to Render if ResendService test passed"
  puts
  puts "Next steps:"
  puts "1. Install the resend gem: bundle install"
  puts "2. If tests pass, deploy to Render"
  puts "3. Add Resend environment variables to Render"
end

begin
  main
rescue => e
  puts "❌ Test script failed: #{e.message}"
  puts "   Make sure you've run 'bundle install' to install the resend gem"
  puts "   Error: #{e.class} - #{e.message}"
end