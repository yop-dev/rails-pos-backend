#!/usr/bin/env ruby

require_relative 'config/environment'

puts "=== Maileroo API Test (Fixed Payload) ==="

# Test sending email via API with corrected format
puts "Testing API email sending with fixed payload..."
maileroo = MailerooService.new

email_result = maileroo.send_email(
  to: 'desilvajoner95@gmail.com',
  subject: 'Fixed Payload Test - Rails POS',
  html_content: '<h1>Success!</h1><p>This email was sent via the corrected Maileroo API payload format.</p>',
  text_content: 'Success! This email was sent via the corrected Maileroo API payload format.'
)

puts "Email result: #{email_result}"
puts

if email_result[:success]
  puts "🎉 SUCCESS! Maileroo API is now working!"
  puts "📧 Check your email: desilvajoner95@gmail.com"
  puts "✅ Ready for Render deployment!"
else
  puts "❌ Still having issues..."
  puts "Error: #{email_result[:error]}"
  
  # Let's also test raw API call to debug
  puts "\n🔍 Debug: Testing raw API call..."
  
  require 'httparty'
  
  payload = {
    to: 'desilvajoner95@gmail.com',
    from: 'rails-pos@railspos.maileroo.app',
    from_name: 'Rails POS',
    subject: 'Raw API Test',
    html: '<p>Raw API test</p>'
  }
  
  headers = {
    'X-API-KEY' => ENV['MAILEROO_API_KEY'],
    'Content-Type' => 'application/json'
  }
  
  response = HTTParty.post('https://smtp.maileroo.com/send', {
    headers: headers,
    body: payload.to_json
  })
  
  puts "Raw API Response: #{response.code} - #{response.body}"
end