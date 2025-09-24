module Types
  class BaseConnection < Types::BaseObject
    # add `nodes` and `pageInfo` fields, as well as `edge_type(...)` and `node_type(...)`
    include GraphQL::Types::Relay::ConnectionBehaviors
  end
end