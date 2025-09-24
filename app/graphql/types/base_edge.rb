module Types
  class BaseEdge < Types::BaseObject
    # add `node` and `cursor` fields, as well as `node_type(...)` and `cursor_type(...)`
    include GraphQL::Types::Relay::EdgeBehaviors
  end
end