module Types
  class OrderPayload < Types::BaseObject
    description "Payload for order mutations"

    field :order, Types::OrderType, null: true, description: "The order that was mutated"
    field :errors, [Types::UserErrorType], null: false, description: "Errors that occurred during the mutation"
  end
end