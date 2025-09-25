module Types
  class UserErrorType < Types::BaseObject
    description "A user-facing error"

    field :message, String, null: false, description: "A description of the error"
    field :field, String, null: true, description: "The field that caused the error"
    field :path, [String], null: true, description: "The path to the input field that caused the error"
  end
end
