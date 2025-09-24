module Mutations
  class DeleteProductCategory < Types::BaseMutation
    description "Delete a product category"

    argument :id, ID, required: true

    field :deleted_id, ID, null: true
    field :success, Boolean, null: false
    field :errors, [Types::UserErrorType], null: false

    def resolve(id:)
      merchant = current_merchant
      category = merchant.product_categories.find_by(id: id)

      unless category
        return {
          deleted_id: nil,
          success: false,
          errors: [{ message: "Product category not found", path: [] }]
        }
      end

      # Check if category has products - this will trigger restrict_with_error
      if category.products.exists?
        return {
          deleted_id: nil,
          success: false,
          errors: [{ message: "Cannot delete category that contains products", path: [] }]
        }
      end

      if category.destroy
        {
          deleted_id: id,
          success: true,
          errors: []
        }
      else
        {
          deleted_id: nil,
          success: false,
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