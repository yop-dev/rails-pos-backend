module Types
  class CreateOrderPayload < Types::BaseObject
    description "Payload for creating an order"

    field :order, Types::OrderType, null: true, description: "The created order"
    field :payment_link, String, null: true, description: "Payment link for online payments"
    field :errors, [Types::UserErrorType], null: false, description: "Errors that occurred during the mutation"
  end
end