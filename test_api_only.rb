#!/usr/bin/env ruby

require_relative 'config/environment'

puts "=== Quick Maileroo API Test ==="

# Test the API connection
puts "Testing API connection..."
maileroo = MailerooService.new
result = maileroo.get_account_info
puts "Account info result: #{result}"
puts

# Test sending email via API
puts "Testing API email sending..."
email_result = maileroo.send_email(
  to: 'desilvajoner95@gmail.com',
  subject: 'Fixed API Test - Rails POS',
  html_content: '<h1>API Fixed!</h1><p>This email was sent via the corrected Maileroo API endpoint.</p>'
)
puts "Email result: #{email_result}"

if email_result[:success]
  puts "✅ API is now working! Check your email."
else
  puts "❌ API still not working. Error: #{email_result[:error]}"
end