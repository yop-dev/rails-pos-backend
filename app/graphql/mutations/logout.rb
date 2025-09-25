module Mutations
  class Logout < BaseMutation
    description "Log out a user"
    
    field :success, Boolean, null: false, description: "Whether logout was successful"
    field :message, String, null: false, description: "Logout message"
    field :errors, [Types::UserErrorType], null: false, description: "Any errors that occurred"
    
    def resolve
      # In a real app, you'd invalidate the JWT token
      {
        success: true,
        message: "Successfully logged out",
        errors: []
      }
    rescue => e
      {
        success: false,
        message: "Logout failed",
        errors: [{ message: e.message, field: "general" }]
      }
    end
  end
end