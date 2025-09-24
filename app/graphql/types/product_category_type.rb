module Types
  class ProductCategoryType < Types::BaseObject
    description "A product category"

    field :id, ID, null: false
    field :name, String, null: false
    field :slug, String, null: true
    field :position, Integer, null: true
    field :products_count, Integer, null: false, description: "Number of products in this category"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def products_count
      object.products_count
    end
  end
end