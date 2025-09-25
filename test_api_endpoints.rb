#!/usr/bin/env ruby

require 'httparty'
require_relative 'config/environment'

puts "=== Testing Different Maileroo API Endpoints ==="

# Common API endpoint patterns to test
endpoints = [
  'https://api.maileroo.com/v1/send',
  'https://api.maileroo.com/send',
  'https://smtp.maileroo.com/api/v1/send',
  'https://smtp.maileroo.com/v1/send',
  'https://maileroo.com/api/send',
  'https://maileroo.com/api/v1/send'
]

api_key = ENV['MAILEROO_API_KEY']

test_payload = {
  to: [{ email: 'desilvajoner95@gmail.com', name: 'Test User' }],
  from: { email: 'rails-pos@railspos.maileroo.app', name: 'Rails POS' },
  subject: 'API Endpoint Test',
  html: '<p>Testing API endpoint</p>'
}

headers = {
  'Authorization' => "Bearer #{api_key}",
  'Content-Type' => 'application/json'
}

endpoints.each do |endpoint|
  puts "\n🧪 Testing: #{endpoint}"
  
  begin
    response = HTTParty.post(endpoint, {
      headers: headers,
      body: test_payload.to_json,
      timeout: 10
    })
    
    puts "   Status: #{response.code}"
    puts "   Response: #{response.body[0..200]}..."
    
    if response.success?
      puts "   ✅ SUCCESS! This endpoint works!"
      break
    else
      puts "   ❌ Failed"
    end
  rescue => e
    puts "   ❌ Error: #{e.message}"
  end
end

puts "\n=== Alternative Headers Test ==="
# Test with X-API-KEY header instead of Authorization
alt_headers = {
  'X-API-KEY' => api_key,
  'Content-Type' => 'application/json'
}

test_endpoint = 'https://smtp.maileroo.com/api/send'
puts "\n🧪 Testing #{test_endpoint} with X-API-KEY header:"

begin
  response = HTTParty.post(test_endpoint, {
    headers: alt_headers,
    body: test_payload.to_json,
    timeout: 10
  })
  
  puts "   Status: #{response.code}"
  puts "   Response: #{response.body}"
  
  if response.success?
    puts "   ✅ SUCCESS with X-API-KEY!"
  else
    puts "   ❌ Failed with X-API-KEY too"
  end
rescue => e
  puts "   ❌ Error: #{e.message}"
end