#!/usr/bin/env ruby

# Email Development Test Script
# This script tests both Maileroo SMTP and API methods
# Run with: ruby test_email_development.rb

require_relative 'config/environment'

puts "=== Rails POS Email Test (Development) ==="
puts "Environment: #{Rails.env}"
puts

# Test email address - change this to your email
TEST_EMAIL = ENV['GMAIL_USERNAME'] || 'your-test-email@example.com'

def test_environment_variables
  puts "🔍 Checking Environment Variables:"
  
  maileroo_vars = [
    'MAILEROO_API_KEY',
    'MAILEROO_SMTP_EMAIL', 
    'MAILEROO_SMTP_PASSWORD',
    'MAILEROO_FROM_EMAIL',
    'MAILEROO_FROM_NAME'
  ]
  
  maileroo_vars.each do |var|
    value = ENV[var]
    if value.present?
      # Show partial value for security
      display_value = case var
      when 'MAILEROO_API_KEY'
        "#{value[0..10]}...#{value[-10..-1]}"
      when 'MAILEROO_SMTP_PASSWORD'
        "#{value[0..3]}...#{value[-3..-1]}"
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

def test_actionmailer_config
  puts "🔍 ActionMailer Configuration:"
  puts "  - Delivery method: #{Rails.application.config.action_mailer.delivery_method}"
  puts "  - Perform deliveries: #{Rails.application.config.action_mailer.perform_deliveries}"
  puts "  - Raise delivery errors: #{Rails.application.config.action_mailer.raise_delivery_errors}"
  
  if Rails.application.config.action_mailer.delivery_method == :smtp
    smtp_settings = Rails.application.config.action_mailer.smtp_settings
    puts "  - SMTP address: #{smtp_settings[:address]}"
    puts "  - SMTP port: #{smtp_settings[:port]}"
    puts "  - SMTP user: #{smtp_settings[:user_name] ? '[SET]' : '[NOT SET]'}"
    puts "  - SMTP password: #{smtp_settings[:password] ? '[SET]' : '[NOT SET]'}"
  end
  puts
end

def test_maileroo_api_connection
  puts "🔍 Testing Maileroo API Connection:"
  
  begin
    maileroo = MailerooService.new
    result = maileroo.get_account_info
    
    if result[:success]
      puts "  ✅ API connection successful"
      if result[:account_info]
        puts "  📊 Account info retrieved"
      end
    else
      puts "  ❌ API connection failed: #{result[:error]}"
    end
  rescue => e
    puts "  ❌ API test error: #{e.message}"
  end
  puts
end

def test_direct_api_email
  puts "🔍 Testing Direct Maileroo API Email:"
  
  begin
    maileroo = MailerooService.new
    
    result = maileroo.send_email(
      to: TEST_EMAIL,
      subject: 'Test Email via Maileroo API',
      html_content: '<h1>Test Email</h1><p>This is a test email sent directly via Maileroo API from Rails POS development environment.</p>',
      text_content: 'Test Email - This is a test email sent directly via Maileroo API from Rails POS development environment.'
    )
    
    if result[:success]
      puts "  ✅ Direct API email sent successfully!"
      puts "  📧 Check your inbox: #{TEST_EMAIL}"
    else
      puts "  ❌ Direct API email failed: #{result[:error]}"
    end
  rescue => e
    puts "  ❌ Direct API test error: #{e.message}"
  end
  puts
end

def test_rails_mailer_smtp
  puts "🔍 Testing Rails ActionMailer with SMTP:"
  
  # Temporarily force SMTP delivery method
  original_method = Rails.application.config.action_mailer.delivery_method
  Rails.application.config.action_mailer.delivery_method = :smtp
  
  begin
    # Create a simple test mailer
    test_mail = ActionMailer::Base.mail(
      from: ENV['MAILEROO_SMTP_EMAIL'] || 'rails-pos@railspos.maileroo.app',
      to: TEST_EMAIL,
      subject: 'Test Email via Rails ActionMailer + Maileroo SMTP',
      body: 'This is a test email sent via Rails ActionMailer using Maileroo SMTP from development environment.'
    )
    
    test_mail.deliver_now
    puts "  ✅ Rails ActionMailer + SMTP email sent successfully!"
    puts "  📧 Check your inbox: #{TEST_EMAIL}"
  rescue => e
    puts "  ❌ Rails ActionMailer + SMTP failed: #{e.message}"
    puts "     Error class: #{e.class}"
  ensure
    # Restore original delivery method
    Rails.application.config.action_mailer.delivery_method = original_method
  end
  puts
end

def test_order_mailer
  puts "🔍 Testing OrderMailer (Full Integration):"
  
  begin
    # Try to find an existing order, or create test data
    order = Order.first
    
    if order.nil?
      puts "  ⚠️  No orders found in database"
      puts "     Create an order through your application to test OrderMailer"
      puts "     Or create test data in Rails console"
    else
      puts "  📋 Using Order ##{order.id} (Reference: #{order.reference})"
      
      # Test the actual OrderMailer
      email = OrderMailer.order_placed(order)
      email.deliver_now
      
      puts "  ✅ OrderMailer email sent successfully!"
      puts "  📧 Check customer inbox: #{order.customer.email}"
    end
  rescue => e
    puts "  ❌ OrderMailer test failed: #{e.message}"
    puts "     Error class: #{e.class}"
  end
  puts
end

def main
  puts "Testing email to: #{TEST_EMAIL}"
  if TEST_EMAIL == 'your-test-email@example.com'
    puts "⚠️  Please update TEST_EMAIL in this script to your actual email address"
    puts
  end
  
  test_environment_variables
  test_actionmailer_config
  test_maileroo_api_connection
  test_direct_api_email
  test_rails_mailer_smtp
  test_order_mailer
  
  puts "=== Test Summary ==="
  puts "✅ If you received emails, your Maileroo integration is working!"
  puts "❌ If you didn't receive emails, check the error messages above"
  puts
  puts "Next steps:"
  puts "1. Check your email inbox (including spam folder)"
  puts "2. If using API method, check Maileroo dashboard for delivery logs"
  puts "3. Create a test order in your Rails application"
  puts "4. Deploy to Render with the same environment variables"
end

begin
  main
rescue => e
  puts "❌ Test script failed: #{e.message}"
  puts "   Make sure you're running this from the rails-pos-backend directory"
  puts "   And that Rails is properly configured"
end