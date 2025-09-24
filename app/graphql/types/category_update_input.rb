module Types
  class CategoryUpdateInput < Types::BaseInputObject
    description "Input arguments for updating an existing product category"

    argument :name, String, required: false
    argument :position, Int, required: false
  end
end