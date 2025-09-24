module Mutations
  class CreateProduct < Types::BaseMutation
    description "Create a new product"

    argument :input, Types::ProductInput, required: true

    field :product, Types::ProductType, null: true
    field :errors, [Types::UserErrorType], null: false

    def resolve(input:)
      merchant = current_merchant
      product = merchant.products.build

      # Set basic attributes
      product.name = input.name
      product.description = input.description
      product.price_cents = input.price_cents
      product.currency = input.currency
      product.product_type = input.product_type

      # Set category if provided
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