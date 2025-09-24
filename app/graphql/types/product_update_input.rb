module Types
  class ProductUpdateInput < Types::BaseInputObject
    description "Input arguments for updating an existing product"

    argument :name, String, required: false
    argument :description, String, required: false
    argument :category_id, ID, required: false
    argument :price_cents, Int, required: false
    argument :currency, String, required: false
    argument :product_type, String, required: false
    argument :photo, String, required: false
    argument :active, Boolean, required: false
  end
end