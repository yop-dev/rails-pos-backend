module Types
  class PaymentOptionType < Types::BaseObject
    description "A payment option"

    field :code, String, null: false, description: "Unique code for the payment method"
    field :label, String, null: false, description: "Human-readable label"
    field :convenience_fee_cents, Integer, null: false, description: "Convenience fee in cents"
    field :convenience_fee, Types::MoneyType, null: false, description: "Convenience fee as a Money object"

    def convenience_fee
      Product::Money.new(object[:convenience_fee_cents], "PHP")
    end
  end
end