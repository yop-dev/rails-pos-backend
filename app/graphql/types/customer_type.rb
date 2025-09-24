module Types
  class CustomerType < Types::BaseObject
    description "A customer"

    field :id, ID, null: false
    field :email, String, null: false
    field :phone, String, null: true
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :full_name, String, null: false, description: "First and last name combined"
    field :default_address, Types::AddressType, null: true
    field :last_checkout_address, Types::AddressType, null: true, description: "Address from the most recent order"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def full_name
      object.full_name
    end

    def default_address
      object.default_address
    end

    def last_checkout_address
      object.last_checkout_address
    end
  end
end