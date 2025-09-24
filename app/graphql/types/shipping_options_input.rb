module Types
  class ShippingOptionsInput < Types::BaseInputObject
    description "Input for shipping options"

    argument :delivery, Types::DeliveryInput, required: false, description: "Delivery address"
    argument :items, [Types::OrderItemInput], required: false, description: "Order items"
  end
end