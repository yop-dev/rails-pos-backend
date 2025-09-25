module Mutations
  class Login < BaseMutation
    description "Authenticate a user"
    
    argument :input, Types::LoginInputType, required: true, description: "Login credentials"
    
    field :user, Types::UserType, null: true, description: "The authenticated user"
    field :token, String, null: true, description: "JWT authentication token"
    field :refreshToken, String, null: true, description: "JWT refresh token"
    field :errors, [Types::UserErrorType], null: false, description: "Any errors that occurred"
    
    def resolve(input:)
      # Find user by email
      user = User.find_by(email: input[:email])
      
      # Debug logging
      Rails.logger.info "Login attempt for email: #{input[:email]}"
      Rails.logger.info "User found: #{user ? 'Yes' : 'No'}"
      if user
        Rails.logger.info "User details: #{user.firstName} #{user.lastName} (#{user.role})"
        Rails.logger.info "Password check: #{user.authenticate(input[:password]) ? 'Success' : 'Failed'}"
      end
      
      # Check if user exists and password is correct
      if user && user.authenticate(input[:password])
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
        {
          user: nil,
          token: nil,
          refreshToken: nil,
          errors: [{ message: "Invalid email or password", field: "email" }]
        }
      end
    rescue => e
      {
        user: nil,
        token: nil,
        refreshToken: nil,
        errors: [{ message: "Authentication failed: #{e.message}", field: "general" }]
      }
    end
  end
end