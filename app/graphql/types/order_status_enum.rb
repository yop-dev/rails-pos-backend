module Types
  class OrderStatusEnum < Types::BaseEnum
    description "Order status"

    value "PENDING", value: "pending", description: "Order is pending confirmation"
    value "CONFIRMED", value: "confirmed", description: "Order has been confirmed"
    value "COMPLETED", value: "completed", description: "Order has been completed"
  end
end