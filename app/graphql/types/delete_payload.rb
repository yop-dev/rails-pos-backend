module Types
  class DeletePayload < Types::BaseObject
    description "Payload for delete mutations"

    field :deleted_id, ID, null: true, description: "ID of the deleted record"
    field :success, Boolean, null: false, description: "Whether the deletion was successful"
    field :errors, [Types::UserErrorType], null: false, description: "Errors that occurred during the mutation"
  end
end