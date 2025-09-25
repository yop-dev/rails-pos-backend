#!/usr/bin/env ruby

require 'httparty'
require_relative 'config/environment'

puts "=== Testing Alternative Field Names ==="

api_key = ENV['MAILEROO_API_KEY']

# Test different field names that might be expected
test_cases = [
  {
    name: "Standard subject",
    payload: {
      to: 'desilvajoner95@gmail.com',
      from: 'rails-pos@railspos.maileroo.app',
      subject: 'Test Email',
      html: '<p>Test content</p>'
    }
  },
  {
    name: "Subject as 'title'",
    payload: {
      to: 'desilvajoner95@gmail.com',
      from: 'rails-pos@railspos.maileroo.app',
      title: 'Test Email',
      html: '<p>Test content</p>'
    }
  },
  {
    name: "Subject as 'email_subject'",
    payload: {
      to: 'desilvajoner95@gmail.com',
      from: 'rails-pos@railspos.maileroo.app',
      email_subject: 'Test Email',
      html: '<p>Test content</p>'
    }
  },
  {
    name: "HTML as 'body'",
    payload: {
      to: 'desilvajoner95@gmail.com',
      from: 'rails-pos@railspos.maileroo.app',
      subject: 'Test Email',
      body: '<p>Test content</p>'
    }
  },
  {
    name: "HTML as 'content'",
    payload: {
      to: 'desilvajoner95@gmail.com',
      from: 'rails-pos@railspos.maileroo.app',
      subject: 'Test Email',
      content: '<p>Test content</p>'
    }
  },
  {
    name: "With message wrapper",
    payload: {
      message: {
        to: 'desilvajoner95@gmail.com',
        from: 'rails-pos@railspos.maileroo.app',
        subject: 'Test Email',
        html: '<p>Test content</p>'
      }
    }
  },
  {
    name: "With email wrapper",
    payload: {
      email: {
        to: 'desilvajoner95@gmail.com',
        from: 'rails-pos@railspos.maileroo.app',
        subject: 'Test Email',
        html: '<p>Test content</p>'
      }
    }
  }
]

test_cases.each_with_index do |test_case, index|
  puts "\n🧪 Test #{index + 1}: #{test_case[:name]}"
  puts "Payload: #{test_case[:payload].to_json}"
  
  response = HTTParty.post('https://smtp.maileroo.com/send', {
    headers: { 'X-API-KEY' => api_key, 'Content-Type' => 'application/json' },
    body: test_case[:payload].to_json
  })
  
  puts "Response: #{response.code} - #{response.body}"
  
  # If we get a different error or success, we found something!
  unless response.body.include?("The subject field is required")
    puts "🎉 DIFFERENT RESPONSE! This might be progress!"
  end
end

puts "\n=== Testing Different Base URLs ==="

# Maybe the base URL is wrong?
base_urls = [
  'https://api.maileroo.com/send',
  'https://maileroo.com/api/send',
  'https://smtp.maileroo.com/api/send'
]

simple_payload = {
  to: 'desilvajoner95@gmail.com',
  from: 'rails-pos@railspos.maileroo.app',
  subject: 'Test Email',
  html: '<p>Test content</p>'
}

base_urls.each do |base_url|
  puts "\n🌐 Testing: #{base_url}"
  
  begin
    response = HTTParty.post(base_url, {
      headers: { 'X-API-KEY' => api_key, 'Content-Type' => 'application/json' },
      body: simple_payload.to_json,
      timeout: 10
    })
    
    puts "Response: #{response.code} - #{response.body}"
    
    unless response.body.include?("The subject field is required")
      puts "🎉 DIFFERENT RESPONSE! This base URL might work!"
    end
  rescue => e
    puts "Error: #{e.message}"
  end
end

puts "\n=== End Tests ==="