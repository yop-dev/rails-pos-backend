module Types
  class OrderType < Types::BaseObject
    description "An order"

    field :id, ID, null: false
    field :reference, String, null: false
    field :source, Types::OrderSourceEnum, null: false
    field :status, Types::OrderStatusEnum, null: false
    field :customer, Types::CustomerType, null: false
    field :delivery_address, Types::AddressType, null: true
    field :items, [Types::OrderItemType], null: false
    field :subtotal_cents, Integer, null: false
    field :shipping_fee_cents, Integer, null: false
    field :convenience_fee_cents, Integer, null: false
    field :total_cents, Integer, null: false
    field :subtotal, Types::MoneyType, null: false
    field :shipping_fee, Types::MoneyType, null: false
    field :convenience_fee, Types::MoneyType, null: false
    field :total, Types::MoneyType, null: false
    field :shipping_method_code, String, null: true
    field :shipping_method_label, String, null: true
    field :payment_method_code, String, null: true
    field :payment_method_label, String, null: true
    field :payment_link, String, null: true
    field :placed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :confirmed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :completed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def items
      object.order_items
    end

    def subtotal
      object.subtotal
    end

    def shipping_fee
      object.shipping_fee
    end

    def convenience_fee
      object.convenience_fee
    end


    def total
      object.total
    end

    def source
      object.source
    end

    def status
      object.status
    end
  end
end