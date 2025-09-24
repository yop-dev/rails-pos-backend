Rails.application.routes.draw do
  # GraphQL endpoint
  post "/graphql", to: "graphql#execute"

  # GraphiQL development interface
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  # Letter opener for email previews in development
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Favicon (to prevent 404 errors)
  get "/favicon.ico", to: proc { [204, {}, []] }

  # Root route
  root "rails/health#show"
end
