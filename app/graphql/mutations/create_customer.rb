module Mutations
  class CreateCustomer < GraphQL::Schema::Mutation
    description "Create a new customer"

    argument :first_name, String, required: true
    argument :last_name, String, required: true
    argument :email, String, required: true
    argument :phone, String, required: false

    field :customer, Types::CustomerType, null: true
    field :errors, [Types::UserErrorType], null: false

    def resolve(first_name:, last_name:, email:, phone: nil)
      merchant = current_merchant
      customer = merchant.customers.build

      # Set basic attributes
      customer.first_name = first_name
      customer.last_name = last_name
      customer.email = email
      customer.phone = phone if phone

      if customer.save
        {
          customer: customer,
          errors: []
        }
      else
        {
          customer: nil,
          errors: format_errors(customer.errors)
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