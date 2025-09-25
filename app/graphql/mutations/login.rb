module Mutations
  class Login < BaseMutation
    description "Authenticate a user"
    
    argument :input, Types::LoginInputType, required: true, description: "Login credentials"
    
    field :user, Types::UserType, null: true, description: "The authenticated user"
    field :token, String, null: true, description: "JWT authentication token"
    field :refreshToken, String, null: true, description: "JWT refresh token"
    field :errors, [Types::UserErrorType], null: false, description: "Any errors that occurred"
    
    def resolve(input:)
      # For now, create a simple mock authentication
      # In production, you'd authenticate against the database
      if input[:email] == "admin@railspos.com" && input[:password] == "password"
        # Create or find the admin user
        user = User.find_or_create_by(email: "admin@railspos.com") do |u|
          u.firstName = "Admin"
          u.lastName = "User"
          u.role = "admin"
          u.password = "password"
        end
        
        # Generate mock tokens (in production, use JWT)
        token = "mock-jwt-#{Time.current.to_i}"
        refresh_token = "mock-refresh-#{Time.current.to_i}"
        
        {
          user: user,
          token: token,
          refresh_token: refresh_token,
          errors: []
        }
      else
        {
          user: nil,
          token: nil,
          refresh_token: nil,
          errors: [{ message: "Invalid email or password", field: "email" }]
        }
      end
    rescue => e
      {
        user: nil,
        token: nil,
        refresh_token: nil,
        errors: [{ message: "Authentication failed: #{e.message}", field: "general" }]
      }
    end
  end
end