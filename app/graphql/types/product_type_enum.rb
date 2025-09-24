module Types
  class ProductTypeEnum < Types::BaseEnum
    description "Product types"

    value "PHYSICAL", value: "physical", description: "Physical product that requires shipping"
    value "DIGITAL", value: "digital", description: "Digital product that can be delivered electronically"
  end
end