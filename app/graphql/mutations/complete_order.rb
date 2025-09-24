module Mutations
  class CompleteOrder < Types::BaseMutation
    description "Complete a confirmed order"

    argument :id, ID, required: true

    field :order, Types::OrderType, null: true
    field :errors, [Types::UserErrorType], null: false

    def resolve(id:)
      merchant = current_merchant
      order = merchant.orders.find_by(id: id)

      unless order
        return {
          order: nil,
          errors: [{ message: "Order not found", path: [] }]
        }
      end

      unless order.can_complete?
        return {
          order: nil,
          errors: [{ message: "Order cannot be completed in its current state", path: [] }]
        }
      end

      if order.complete!
        {
          order: order,
          errors: []
        }
      else
        {
          order: nil,
          errors: format_errors(order.errors)
        }
      end
    end

    private

    def current_merchant
      context[:current_merchant] || Merchant.first
    end

    def format_errors(active_record_errors)
      active_record_errors.full_messages.map do |message|
        {
          message: message,
          path: []
        }
      end
    end
  end
end