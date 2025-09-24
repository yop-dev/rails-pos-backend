module Types
  class OrderInput < Types::BaseInputObject
    description "Input arguments for creating a new order"

    argument :source, Types::OrderSourceEnum, required: true
    argument :items, [Types::OrderItemInput], required: true
    argument :customer, Types::CustomerInput, required: false
    argument :customer_id, ID, required: false
    argument :delivery_address, Types::AddressInput, required: false
    argument :payment_method_code, String, required: true
    argument :notes, String, required: false
  end
end