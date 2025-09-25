#!/usr/bin/env ruby

require_relative 'config/environment'

puts "=== Resend Client Methods Debug ==="

begin
  require 'resend'
  api_key = ENV['RESEND_API_KEY']
  
  puts "Creating Resend client..."
  # Try the global configuration method that seemed to work
  Resend.api_key = api_key
  client = Resend::Client.new
  
  puts "✅ Client created successfully"
  puts "Client class: #{client.class}"
  
  puts "\n🔍 Available methods containing 'send' or 'email':"
  send_methods = client.methods.grep(/send|email/)
  send_methods.each { |method| puts "  - #{method}" }
  
  puts "\n🔍 All public methods:"
  client.public_methods(false).sort.each { |method| puts "  - #{method}" }
  
  puts "\n🧪 Testing different API calls..."
  
  test_params = {
    from: 'Rails POS <noreply@yopn8n.cfd>',
    to: ['desilvajoner95@gmail.com'],
    subject: 'Resend API Method Test',
    html: '<h1>Testing API method</h1><p>This is a test to find the correct API method.</p>'
  }
  
  # Try different methods
  methods_to_try = [
    -> { client.emails.send(test_params) },
    -> { client.send_email(test_params) },
    -> { client.send(test_params) },
    -> { Resend::Emails.send(test_params) },
    -> { Resend.emails.send(test_params) }
  ]
  
  methods_to_try.each_with_index do |method_call, index|
    begin
      puts "\nTrying method #{index + 1}..."
      result = method_call.call
      puts "✅ SUCCESS with method #{index + 1}!"
      puts "Result: #{result}"
      break
    rescue => e
      puts "❌ Method #{index + 1} failed: #{e.message}"
    end
  end
  
rescue => e
  puts "❌ Error: #{e.message}"
  puts "Make sure the resend gem is installed: bundle install"
end