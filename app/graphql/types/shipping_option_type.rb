module Types
  class ShippingOptionType < Types::BaseObject
    description "A shipping option"

    field :code, String, null: false, description: "Unique code for the shipping method"
    field :label, String, null: false, description: "Human-readable label"
    field :fee_cents, Integer, null: false, description: "Shipping fee in cents"
    field :fee, Types::MoneyType, null: false, description: "Shipping fee as a Money object"

    def fee
      Product::Money.new(object[:fee_cents], "PHP")
    end
  end
end