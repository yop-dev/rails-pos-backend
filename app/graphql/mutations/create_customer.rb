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
      
      # Check if customer already exists
      existing_customer = merchant.customers.find_by(email: email)
      if existing_customer
        Rails.logger.info "Customer already exists with email: #{email}"
        return {
          customer: existing_customer,
          errors: [{ message: "Customer with this email already exists", path: ["email"] }]
        }
      end
      
      customer = merchant.customers.build

      # Set basic attributes
      customer.first_name = first_name
      customer.last_name = last_name
      customer.email = email
      customer.phone = phone if phone
      
      Rails.logger.info "Attempting to create customer: #{email}, #{first_name} #{last_name}"

      if customer.save
        Rails.logger.info "Customer created successfully: #{customer.id}"
        {
          customer: customer,
          errors: []
        }
      else
        Rails.logger.error "Failed to create customer: #{customer.errors.full_messages.join(', ')}"
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