module Types
  class OrderSourceEnum < Types::BaseEnum
    description "Order source"

    value "ONLINE", value: "online", description: "Order placed online"
    value "IN_STORE", value: "in_store", description: "Order placed in store"
  end
end