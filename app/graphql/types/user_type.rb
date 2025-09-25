module Types
  class UserType < Types::BaseObject
    description "A user of the system"
    
    field :id, ID, null: false, description: "The user's unique identifier"
    field :firstName, String, null: false, description: "The user's first name"  
    field :lastName, String, null: false, description: "The user's last name"
    field :email, String, null: false, description: "The user's email address"
    field :role, String, null: false, description: "The user's role (admin or staff)"
    field :createdAt, GraphQL::Types::ISO8601DateTime, null: false, description: "When the user was created", method: :created_at
  end
end