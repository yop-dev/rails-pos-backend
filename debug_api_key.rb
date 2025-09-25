#!/usr/bin/env ruby

require_relative 'config/environment'

puts "=== API Key Debug ==="

api_key = ENV['RESEND_API_KEY']

puts "API Key present: #{api_key ? 'YES' : 'NO'}"
puts "API Key class: #{api_key.class}"
puts "API Key length: #{api_key&.length}"
puts "API Key starts with: #{api_key&.[](0..10)}"
puts "API Key ends with: #{api_key&.[](-10..-1)}"
puts "API Key is string?: #{api_key.is_a?(String)}"

# Test string conversion
puts
puts "After .to_s:"
api_key_str = api_key.to_s
puts "String class: #{api_key_str.class}"
puts "String length: #{api_key_str.length}"

# Test Resend client creation
puts
puts "Testing Resend client creation:"

begin
  require 'resend'
  client = Resend::Client.new(api_key: api_key_str)
  puts "✅ Resend client created successfully"
rescue => e
  puts "❌ Resend client error: #{e.message}"
  puts "   Error class: #{e.class}"
end