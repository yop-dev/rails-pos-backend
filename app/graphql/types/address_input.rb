module Types
  class AddressInput < Types::BaseInputObject
    description "Address input"

    argument :line1, String, required: true, description: "Address line 1"
    argument :line2, String, required: false, description: "Address line 2"
    argument :city, String, required: true, description: "City"
    argument :state, String, required: false, description: "State/Province"
    argument :postal_code, String, required: true, description: "Postal code"
    argument :country, String, required: true, description: "Country"
  end
end