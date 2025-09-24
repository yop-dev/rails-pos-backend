module Types
  class AddressType < Types::BaseObject
    description "An address"

    field :id, ID, null: false
    field :street, String, null: false
    field :unit_floor_building, String, null: true
    field :barangay, String, null: false
    field :city, String, null: false
    field :province, String, null: false
    field :postal_code, String, null: true
    field :landmark, String, null: true
    field :remarks, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end