module Types
  class MoneyType < Types::BaseObject
    description "A monetary value with currency"

    field :cents, Integer, null: false, description: "Amount in cents"
    field :currency, String, null: false, description: "ISO currency code"
    field :formatted, String, null: false, description: "Human-readable formatted amount"

    def formatted
      object.formatted
    end
  end
end