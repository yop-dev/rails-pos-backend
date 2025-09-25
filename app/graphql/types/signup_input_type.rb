module Types
  class SignupInputType < Types::BaseInputObject
    description "Input for user signup"
    
    argument :firstName, String, required: true, description: "The user's first name"
    argument :lastName, String, required: true, description: "The user's last name"
    argument :email, String, required: true, description: "The user's email address"
    argument :password, String, required: true, description: "The user's password"
    argument :role, String, required: false, description: "The user's role (defaults to staff)"
  end
end