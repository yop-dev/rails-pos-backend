module Types
  class ProductsFilterInput < Types::BaseInputObject
    description "Filter options for products"

    argument :category_id, ID, required: false, description: "Filter by category ID"
    argument :search, String, required: false, description: "Search term for product name or description"
    argument :active, Boolean, required: false, description: "Filter by active status"
  end
end