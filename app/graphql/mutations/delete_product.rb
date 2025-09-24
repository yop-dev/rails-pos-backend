module Mutations
  class DeleteProduct < Types::BaseMutation
    description "Delete a product"

    argument :id, ID, required: true

    field :deleted_id, ID, null: true
    field :success, Boolean, null: false
    field :errors, [Types::UserErrorType], null: false

    def resolve(id:)
      merchant = current_merchant
      product = merchant.products.find_by(id: id)

      unless product
        return {
          deleted_id: nil,
          success: false,
          errors: [{ message: "Product not found", path: [] }]
        }
      end

      # Check if product is used in any orders
      if product.order_items.exists?
        return {
          deleted_id: nil,
          success: false,
          errors: [{ message: "Cannot delete product that has been ordered", path: [] }]
        }
      end

      # Store photo info for cleanup
      photo_public_id = product.photo_public_id

      if product.destroy
        # Clean up photo if it exists
        if photo_public_id
          CloudinaryService.delete_asset(photo_public_id)
        end

        {
          deleted_id: id,
          success: true,
          errors: []
        }
      else
        {
          deleted_id: nil,
          success: false,
          errors: format_errors(product.errors)
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