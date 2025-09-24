module Types
  class ErrorType < Types::BaseObject
    description "A simple error type"

    field :message, String, null: false, description: "Error message"
    field :field, String, null: true, description: "Field that caused the error"
    field :code, String, null: true, description: "Error code"
  end
end