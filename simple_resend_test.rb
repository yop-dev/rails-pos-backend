#!/usr/bin/env ruby

require_relative 'config/environment'

puts "=== Simple Resend Test ==="
puts "Environment: #{Rails.env}"
puts

# Test email
TEST_EMAIL = 'desilvajoner95@gmail.com'

# Check environment variables
puts "🔍 Environment Variables:"
puts "  RESEND_API_KEY: #{ENV['RESEND_API_KEY'] ? 'SET' : 'NOT SET'}"
puts "  RESEND_FROM_EMAIL: #{ENV['RESEND_FROM_EMAIL'] || 'NOT SET'}"
puts "  RESEND_FROM_NAME: #{ENV['RESEND_FROM_NAME'] || 'NOT SET'}"
puts

# Check ActionMailer config
puts "🔍 ActionMailer Config:"
puts "  Delivery method: #{Rails.application.config.action_mailer.delivery_method}"
puts

# Test ResendService directly
puts "🧪 Testing ResendService..."

begin
  resend = ResendService.new
  
  result = resend.send_email(
    to: TEST_EMAIL,
    subject: 'Resend Test - Rails POS',
    html_content: '<h1>Success!</h1><p>Resend is working with Rails POS!</p>'
  )
  
  if result[:success]
    puts "✅ SUCCESS! Resend email sent!"
    puts "📧 Check your email: #{TEST_EMAIL}"
  else
    puts "❌ FAILED: #{result[:error]}"
  end
  
rescue => e
  puts "❌ ERROR: #{e.message}"
  puts "   Make sure you ran 'bundle install' to install the resend gem"
end

puts
puts "=== Test Complete ==="