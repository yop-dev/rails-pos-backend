module Mutations
  class CreateCategory < Types::BaseMutation
    description "Create a new product category"

    argument :name, String, required: true
    argument :position, Integer, required: false

    field :category, Types::ProductCategoryType, null: true
    field :errors, [Types::UserErrorType], null: false

    def resolve(name:, position: nil)
      merchant = current_merchant
      category = merchant.product_categories.build

      category.name = name
      category.position = position if position

      if category.save
        {
          category: category,
          errors: []
        }
      else
        {
          category: nil,
          errors: format_errors(category.errors)
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