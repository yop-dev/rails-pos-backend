module Types
  class PaymentPayloadInput < Types::BaseInputObject
    description "Input for payment payload data"

    argument :payment_method_code, String, required: true
    argument :order_id, ID, required: true
    argument :amount_cents, Int, required: true
    argument :currency, String, required: false, default_value: "USD"
    argument :metadata, GraphQL::Types::JSON, required: false
  end
end