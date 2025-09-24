module Types
  class ProductType < Types::BaseObject
    description "A product"

    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :category, Types::ProductCategoryType, null: true
    field :product_type, Types::ProductTypeEnum, null: false
    field :price_cents, Integer, null: false
    field :price, Types::MoneyType, null: false, description: "Price as a Money object"
    field :currency, String, null: false
    field :photo_url, String, null: true, description: "URL to the product photo"
    field :active, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def category
      object.product_category
    end

    def price
      object.price
    end

    def product_type
      object.product_type
    end
  end
end