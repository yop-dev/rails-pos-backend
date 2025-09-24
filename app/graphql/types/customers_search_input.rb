module Types
  class CustomersSearchInput < Types::BaseInputObject
    description "Search options for customers"

    argument :email, String, required: false, description: "Search by email"
    argument :phone, String, required: false, description: "Search by phone"
    argument :term, String, required: false, description: "General search term"
  end
end