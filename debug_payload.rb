#!/usr/bin/env ruby

require 'httparty'
require_relative 'config/environment'

puts "=== Debug Maileroo Payload ==="

# Let's test different payload formats based on common API patterns

api_key = ENV['MAILEROO_API_KEY']
puts "API Key present: #{api_key ? 'YES' : 'NO'}"
puts "API Key length: #{api_key&.length}"
puts

# Test 1: Current format
puts "🧪 Test 1: Current format"
payload1 = {
  to: 'desilvajoner95@gmail.com',
  from: 'rails-pos@railspos.maileroo.app',
  from_name: 'Rails POS',
  subject: 'Test 1',
  html: '<p>Test 1</p>'
}
puts "Payload 1: #{payload1.to_json}"

response1 = HTTParty.post('https://smtp.maileroo.com/send', {
  headers: { 'X-API-KEY' => api_key, 'Content-Type' => 'application/json' },
  body: payload1.to_json
})
puts "Response 1: #{response1.code} - #{response1.body}"
puts

# Test 2: With recipient as object
puts "🧪 Test 2: Recipient as object"
payload2 = {
  to: { email: 'desilvajoner95@gmail.com' },
  from: 'rails-pos@railspos.maileroo.app',
  from_name: 'Rails POS',
  subject: 'Test 2',
  html: '<p>Test 2</p>'
}
puts "Payload 2: #{payload2.to_json}"

response2 = HTTParty.post('https://smtp.maileroo.com/send', {
  headers: { 'X-API-KEY' => api_key, 'Content-Type' => 'application/json' },
  body: payload2.to_json
})
puts "Response 2: #{response2.code} - #{response2.body}"
puts

# Test 3: With both from as object
puts "🧪 Test 3: Both from and to as objects"
payload3 = {
  to: { email: 'desilvajoner95@gmail.com' },
  from: { email: 'rails-pos@railspos.maileroo.app', name: 'Rails POS' },
  subject: 'Test 3',
  html: '<p>Test 3</p>'
}
puts "Payload 3: #{payload3.to_json}"

response3 = HTTParty.post('https://smtp.maileroo.com/send', {
  headers: { 'X-API-KEY' => api_key, 'Content-Type' => 'application/json' },
  body: payload3.to_json
})
puts "Response 3: #{response3.code} - #{response3.body}"
puts

# Test 4: Array format
puts "🧪 Test 4: Array format"
payload4 = {
  to: [{ email: 'desilvajoner95@gmail.com' }],
  from: { email: 'rails-pos@railspos.maileroo.app', name: 'Rails POS' },
  subject: 'Test 4',
  html: '<p>Test 4</p>'
}
puts "Payload 4: #{payload4.to_json}"

response4 = HTTParty.post('https://smtp.maileroo.com/send', {
  headers: { 'X-API-KEY' => api_key, 'Content-Type' => 'application/json' },
  body: payload4.to_json
})
puts "Response 4: #{response4.code} - #{response4.body}"
puts

# Test 5: Different endpoint
puts "🧪 Test 5: Different endpoint (/api/v1/send)"
response5 = HTTParty.post('https://smtp.maileroo.com/api/v1/send', {
  headers: { 'X-API-KEY' => api_key, 'Content-Type' => 'application/json' },
  body: payload1.to_json
})
puts "Response 5: #{response5.code} - #{response5.body}"
puts

# Test 6: Authorization Bearer header
puts "🧪 Test 6: Authorization Bearer header"
response6 = HTTParty.post('https://smtp.maileroo.com/send', {
  headers: { 'Authorization' => "Bearer #{api_key}", 'Content-Type' => 'application/json' },
  body: payload1.to_json
})
puts "Response 6: #{response6.code} - #{response6.body}"
puts

puts "=== End Debug ==="