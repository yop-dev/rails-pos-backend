module Types
  class LoginInputType < Types::BaseInputObject
    description "Input for user login"
    
    argument :email, String, required: true, description: "The user's email address"
    argument :password, String, required: true, description: "The user's password"
  end
end