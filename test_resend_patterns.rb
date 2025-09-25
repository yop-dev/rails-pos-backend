#!/usr/bin/env ruby

require_relative 'config/environment'

puts "=== Testing Resend Gem Patterns ==="

api_key = ENV['RESEND_API_KEY']
puts "API Key: #{api_key[0..10]}...#{api_key[-5..-1]}"

# Test different initialization and usage patterns
patterns = [
  {
    name: "Pattern 1: Client with api_key parameter",
    test: -> {
      client = Resend::Client.new(api_key: api_key)
      client.emails.send({
        from: 'Rails POS <noreply@yopn8n.cfd>',
        to: ['desilvajoner95@gmail.com'],
        subject: 'Test Pattern 1',
        html: '<p>Testing Pattern 1</p>'
      })
    }
  },
  {
    name: "Pattern 2: Client with positional argument",
    test: -> {
      client = Resend::Client.new(api_key)
      client.emails.send({
        from: 'Rails POS <noreply@yopn8n.cfd>',
        to: ['desilvajoner95@gmail.com'],
        subject: 'Test Pattern 2',
        html: '<p>Testing Pattern 2</p>'
      })
    }
  },
  {
    name: "Pattern 3: Global configuration then client",
    test: -> {
      Resend.api_key = api_key
      client = Resend::Client.new
      client.emails.send({
        from: 'Rails POS <noreply@yopn8n.cfd>',
        to: ['desilvajoner95@gmail.com'],
        subject: 'Test Pattern 3',
        html: '<p>Testing Pattern 3</p>'
      })
    }
  },
  {
    name: "Pattern 4: Direct class method",
    test: -> {
      Resend.api_key = api_key
      Resend::Emails.send({
        from: 'Rails POS <noreply@yopn8n.cfd>',
        to: ['desilvajoner95@gmail.com'],
        subject: 'Test Pattern 4',
        html: '<p>Testing Pattern 4</p>'
      })
    }
  },
  {
    name: "Pattern 5: Module method",
    test: -> {
      Resend.api_key = api_key
      Resend.emails.send({
        from: 'Rails POS <noreply@yopn8n.cfd>',
        to: ['desilvajoner95@gmail.com'],
        subject: 'Test Pattern 5',
        html: '<p>Testing Pattern 5</p>'
      })
    }
  }
]

patterns.each do |pattern|
  puts "\n🧪 #{pattern[:name]}"
  begin
    result = pattern[:test].call
    puts "   ✅ SUCCESS!"
    puts "   Result: #{result}"
    puts "   🎉 Found working pattern! Check your email."
    break  # Stop on first success
  rescue => e
    puts "   ❌ Failed: #{e.message}"
  end
end

puts "\n=== Test Complete ==="