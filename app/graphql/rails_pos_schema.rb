class RailsPosSchema < GraphQL::Schema
  # Prevent redefinition errors in development mode
  unless @_schema_configured
    query(Types::QueryType)
    mutation(Types::MutationType)
    @_schema_configured = true
  end
end
