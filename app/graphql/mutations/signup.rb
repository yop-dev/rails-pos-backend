module Mutations
  class Signup < BaseMutation
    description "Register a new user"
    
    argument :input, Types::SignupInputType, required: true, description: "Signup details"
    
    field :user, Types::UserType, null: true, description: "The created user"
    field :token, String, null: true, description: "JWT authentication token"
    field :refreshToken, String, null: true, description: "JWT refresh token"
    field :errors, [Types::UserErrorType], null: false, description: "Any errors that occurred"
    
    def resolve(input:)
      # Debug logging
      Rails.logger.info "Signup attempt for email: #{input[:email]}"
      Rails.logger.info "User details: #{input[:firstName]} #{input[:lastName]}, Role: #{input[:role] || 'staff'}"
      
      # Create new user
      user = User.new(
        firstName: input[:firstName],
        lastName: input[:lastName],
        email: input[:email],
        password: input[:password],
        role: input[:role] || 'staff'
      )
      
      Rails.logger.info "User created in memory, attempting to save..."
      
      if user.save
        Rails.logger.info "User saved successfully with ID: #{user.id}"
        # Generate mock tokens (in production, use JWT)
        token = "mock-jwt-#{Time.current.to_i}"
        refresh_token = "mock-refresh-#{Time.current.to_i}"
        
        {
          user: user,
          token: token,
          refreshToken: refresh_token,
          errors: []
        }
      else
        Rails.logger.error "User save failed with errors: #{user.errors.full_messages.join(', ')}"
        
        # Convert Rails validation errors to GraphQL format
        graphql_errors = user.errors.map do |error|
          {
            message: error.full_message,
            field: error.attribute.to_s
          }
        end
        
        {
          user: nil,
          token: nil,
          refreshToken: nil,
          errors: graphql_errors
        }
      end
    rescue => e
      {
        user: nil,
        token: nil,
        refreshToken: nil,
        errors: [{ message: "Signup failed: #{e.message}", field: "general" }]
      }
    end
  end
end