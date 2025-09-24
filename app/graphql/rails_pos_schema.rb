class RailsPosSchema < GraphQL::Schema
  query(Types::QueryType)
  mutation(Types::MutationType)

  # Error handling temporarily disabled to see actual errors
  # rescue_from(StandardError) do |err, obj, args, ctx, field|
  #   Rails.logger.error "GraphQL error: #{err.message}"
  #   Rails.logger.error err.backtrace.join("\n")
  #   
  #   GraphQL::ExecutionError.new("An error occurred while processing your request")
  # end
end
