#!/usr/bin/env ruby

puts "Debugging GraphQL Schema Loading Issues"
puts "======================================="

# Check if Rails is properly loaded
begin
  require_relative 'config/environment'
  puts "✓ Rails environment loaded successfully"
rescue => e
  puts "✗ Failed to load Rails environment: #{e.message}"
  exit 1
end

# Check if schema classes are properly defined
puts "\nChecking GraphQL classes..."

begin
  if defined?(Types::QueryType)
    puts "✓ Types::QueryType is defined"
  else
    puts "✗ Types::QueryType is not defined"
  end

  if defined?(Types::MutationType)
    puts "✓ Types::MutationType is defined"
  else
    puts "✗ Types::MutationType is not defined"
  end

  if defined?(RailsPosSchema)
    puts "✓ RailsPosSchema is defined"
  else
    puts "✗ RailsPosSchema is not defined"
  end
rescue => e
  puts "✗ Error checking GraphQL classes: #{e.message}"
end

# Try to generate schema definition
puts "\nTrying to generate schema definition..."
begin
  schema_def = RailsPosSchema.to_definition
  puts "✓ Schema definition generated successfully"
  puts "Schema has #{schema_def.lines.count} lines"
rescue => e
  puts "✗ Failed to generate schema definition: #{e.message}"
  puts "Error backtrace:"
  puts e.backtrace.first(5).join("\n")
end

# Try to execute a simple query
puts "\nTrying to execute a simple introspection query..."
begin
  result = RailsPosSchema.execute('{ __schema { types { name } } }')
  if result['errors']
    puts "✗ Query execution failed with errors:"
    result['errors'].each { |error| puts "  - #{error['message']}" }
  else
    puts "✓ Simple introspection query executed successfully"
    puts "Schema has #{result['data']['__schema']['types'].count} types"
  end
rescue => e
  puts "✗ Failed to execute query: #{e.message}"
  puts "Error backtrace:"
  puts e.backtrace.first(5).join("\n")
end

puts "\nDebugging complete. Check the output above for issues."