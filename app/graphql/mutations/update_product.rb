module Mutations
  class UpdateProduct < Types::BaseMutation
    description "Update an existing product"

    argument :input, Types::ProductUpdateInput, required: true

    field :product, Types::ProductType, null: true
    field :errors, [Types::UserErrorType], null: false

    def resolve(input:)
      merchant = current_merchant
      product = merchant.products.find_by(id: input.id)

      unless product
        return {
          product: nil,
          errors: [{ message: "Product not found", path: [] }]
        }
      end

      # Store old photo info for cleanup
      old_photo_public_id = product.photo_public_id

      # Update basic attributes
      product.name = input.name if input.name
      product.description = input.description if input.description.present?
      product.price_cents = input.price_cents if input.price_cents
      product.currency = input.currency if input.currency
      product.product_type = input.product_type if input.product_type
      product.active = input.active unless input.active.nil?

      # Update category if provided
      if input.category_id
        category = merchant.product_categories.find_by(id: input.category_id)
        if category
          product.product_category = category
        else
          return {
            product: nil,
            errors: [{ message: "Product category not found", path: ["category_id"] }]
          }
        end
      end

      # Handle photo upload (temporarily disabled)
      # TODO: Implement proper GraphQL Upload scalar support
      # if input.photo
      #   upload_result = CloudinaryService.upload_product_photo(input.photo, merchant.id)
      #   if upload_result[:error]
      #     return {
      #       product: nil,
      #       errors: [{ message: "Photo upload failed: #{upload_result[:error]}", path: ["photo"] }]
      #     }
      #   end
      #   
      #   product.photo_public_id = upload_result[:public_id]
      #   product.photo_url = upload_result[:url]
      # end

      if product.save
        # Clean up old photo if a new one was uploaded
        if input.photo && old_photo_public_id
          CloudinaryService.delete_asset(old_photo_public_id)
        end

        {
          product: product,
          errors: []
        }
      else
        {
          product: nil,
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