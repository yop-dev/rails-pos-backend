module Types
  class ProductPayload < Types::BaseObject
    description "Payload for product mutations"

    field :product, Types::ProductType, null: true, description: "The product that was mutated"
    field :errors, [Types::UserErrorType], null: false, description: "Errors that occurred during the mutation"
  end
end