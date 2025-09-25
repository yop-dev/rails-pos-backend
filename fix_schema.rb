#!/usr/bin/env ruby

puts "Fixing GraphQL Schema Duplicate Definition Issue"
puts "==============================================="

# Load Rails environment
require_relative 'config/environment'

puts "Rails environment loaded"

# Clear any existing schema definitions
puts "Clearing existing schema definitions..."

# Remove existing schema constant if it exists
if defined?(RailsPosSchema)
  Object.send(:remove_const, :RailsPosSchema)
  puts "✓ Removed existing RailsPosSchema constant"
end

# Force reload of GraphQL types
puts "Reloading GraphQL types..."

# Clear autoloaded constants
if Rails.application.config.cache_classes == false
  Rails.application.reloader.reload!
  puts "✓ Reloaded Rails application"
end

# Manually require the schema file
puts "Loading schema file..."
load Rails.root.join('app', 'graphql', 'rails_pos_schema.rb')
puts "✓ Schema file loaded"

# Test the schema
puts "Testing schema..."
begin
  result = RailsPosSchema.execute('{ __schema { types { name } } }')
  if result['errors']
    puts "✗ Schema test failed:"
    result['errors'].each { |error| puts "  - #{error['message']}" }
  else
    puts "✓ Schema test passed"
  end
rescue => e
  puts "✗ Schema test failed: #{e.message}"
end

puts "Fix attempt complete. Please restart the Rails server."