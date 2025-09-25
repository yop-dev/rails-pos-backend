module Types
  class ProductUpdateInput < Types::BaseInputObject
    description "Input arguments for updating an existing product"

    argument :id, ID, required: true, description: "Product ID to update"
    argument :name, String, required: false, description: "Product name"
    argument :description, String, required: false, description: "Product description"
    argument :category_id, ID, required: false, description: "Product category ID"
    argument :price_cents, Integer, required: false, description: "Price in cents"
    argument :currency, String, required: false, description: "Currency code"
    argument :product_type, Types::ProductTypeEnum, required: false, description: "Product type"
    argument :photo, Types::Upload, required: false, description: "Product photo to upload"
    argument :active, Boolean, required: false, description: "Whether product is active"
  end
end