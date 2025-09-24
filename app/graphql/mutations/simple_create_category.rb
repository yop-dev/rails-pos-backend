module Mutations
  class SimpleCreateCategory < Types::BaseMutation
    description "Create a new product category - simple version"

    argument :name, String, required: true
    argument :position, Integer, required: false

    field :success, Boolean, null: false
    field :category_id, ID, null: true
    field :category_name, String, null: true

    def resolve(name:, position: nil)
      merchant = context[:current_merchant] || Merchant.first
      category = merchant.product_categories.create(
        name: name,
        position: position || 1
      )

      if category.persisted?
        {
          success: true,
          category_id: category.id,
          category_name: category.name
        }
      else
        {
          success: false,
          category_id: nil,
          category_name: nil
        }
      end
    end
  end
end