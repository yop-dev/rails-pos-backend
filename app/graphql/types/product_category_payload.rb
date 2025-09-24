module Types
  class ProductCategoryPayload < Types::BaseObject
    description "Payload for product category mutations"

    field :category, Types::ProductCategoryType, null: true, description: "The category that was mutated"
    field :errors, [Types::UserErrorType], null: false, description: "Errors that occurred during the mutation"
  end
end