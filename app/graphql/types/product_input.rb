module Types
  class ProductInput < Types::BaseInputObject
    description "Input for creating a product"

    argument :name, String, required: true, description: "Product name"
    argument :description, String, required: false, description: "Product description"
    argument :category_id, ID, required: false, description: "Product category ID"
    argument :price_cents, Integer, required: true, description: "Price in cents"
    argument :currency, String, required: false, default_value: "PHP", description: "Currency code"
    argument :product_type, Types::ProductTypeEnum, required: false, default_value: "physical", description: "Product type"
    argument :photo, Types::Upload, required: false, description: "Product photo to upload"
  end
end