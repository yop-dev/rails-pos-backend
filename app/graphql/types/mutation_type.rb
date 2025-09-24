module Types
  class MutationType < Types::BaseObject
    description "The mutation root of this schema"

    # Product mutations
    field :create_product, mutation: Mutations::CreateProduct
    field :update_product, mutation: Mutations::UpdateProduct
    field :delete_product, mutation: Mutations::DeleteProduct

    # Product category mutations
    field :create_category, mutation: Mutations::CreateCategory
    field :simple_create_category, mutation: Mutations::SimpleCreateCategory
    field :update_product_category, mutation: Mutations::UpdateProductCategory
    field :delete_product_category, mutation: Mutations::DeleteProductCategory

    # Order mutations
    field :create_order, mutation: Mutations::CreateOrder
    field :confirm_order, mutation: Mutations::ConfirmOrder
    field :complete_order, mutation: Mutations::CompleteOrder

    # Customer mutations
    field :create_customer, mutation: Mutations::CreateCustomer
  end
end
