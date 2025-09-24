module Types
  class OrderItemType < Types::BaseObject
    description "An order item"

    field :id, ID, null: false
    field :product, Types::ProductType, null: false
    field :product_name, String, null: false, description: "Snapshot of product name at time of order"
    field :unit_price_cents, Integer, null: false
    field :unit_price, Types::MoneyType, null: false
    field :quantity, Integer, null: false
    field :total_price_cents, Integer, null: false
    field :total_price, Types::MoneyType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def product_name
      object.product_name
    end

    def unit_price
      object.unit_price
    end

    def total_price
      object.total_price
    end
  end
end