module Types
  class CustomerInput < Types::BaseInputObject
    description "Customer input"

    argument :first_name, String, required: true, description: "First name"
    argument :last_name, String, required: true, description: "Last name"
    argument :email, String, required: true, description: "Email address"
    argument :phone, String, required: false, description: "Phone number"
  end
end