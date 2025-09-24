module Types
  class BaseField < GraphQL::Schema::Field
    argument_class Types::BaseArgument

    def initialize(*args, **kwargs, &block)
      super
    end
  end
end