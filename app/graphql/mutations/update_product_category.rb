module Mutations
  class UpdateProductCategory < Types::BaseMutation
    description "Update an existing product category"

    argument :id, ID, required: true
    argument :input, Types::CategoryUpdateInput, required: true

    field :category, Types::ProductCategoryType, null: true
    field :errors, [Types::UserErrorType], null: false

    def resolve(id:, input:)
      merchant = current_merchant
      category = merchant.product_categories.find_by(id: id)

      unless category
        return {
          category: nil,
          errors: [{ message: "Product category not found", path: [] }]
        }
      end

      category.name = input.name if input.name
      category.position = input.position if input.position

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