module Types
  class OrderItemInput < Types::BaseInputObject
    description "Order item input"

    argument :product_id, ID, required: true, description: "Product ID"
    argument :quantity, Integer, required: true, description: "Quantity"
  end
end