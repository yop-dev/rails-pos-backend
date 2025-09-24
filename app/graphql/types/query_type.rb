module Types
  class QueryType < Types::BaseObject
    description "The query root of this schema"

    # Product-related queries
    field :product_categories, [Types::ProductCategoryType], null: false,
          description: "Get all product categories for the current merchant"
    
    field :products, [Types::ProductType], null: false,
          description: "Get products with optional filtering" do
      argument :filter, Types::ProductsFilterInput, required: false
      argument :first, Integer, required: false
      argument :after, String, required: false
    end

    # Customer-related queries
    field :customers, [Types::CustomerType], null: false,
          description: "Search for customers" do
      argument :search, Types::CustomersSearchInput, required: true
      argument :first, Integer, required: false
      argument :after, String, required: false
    end

    # Order-related queries
    field :orders, [Types::OrderType], null: false,
          description: "Get all orders for the current merchant"
    
    field :order, Types::OrderType, null: true,
          description: "Get a single order by ID or reference" do
      argument :id, ID, required: false
      argument :reference, String, required: false
    end

    # Shipping and payment queries
    field :shipping_options, [Types::ShippingOptionType], null: false,
          description: "Get available shipping options" do
      argument :input, Types::ShippingOptionsInput, required: true
    end

    field :payment_options, [Types::PaymentOptionType], null: false,
          description: "Get available payment options"

    # Resolvers
    def product_categories
      current_merchant.product_categories.ordered
    end

    def products(filter: nil, first: nil, after: nil)
      scope = current_merchant.products.includes(:product_category)
      
      if filter
        scope = scope.by_category(filter[:category_id]) if filter[:category_id]
        scope = scope.search(filter[:search]) if filter[:search]
        scope = scope.where(active: filter[:active]) unless filter[:active].nil?
      end
      
      scope.order(:name)
    end

    def customers(search:, first: nil, after: nil)
      scope = current_merchant.customers
      
      if search[:email]
        scope = scope.search_by_email(search[:email])
      elsif search[:phone]
        scope = scope.search_by_phone(search[:phone])
      elsif search[:term]
        scope = scope.search_by_term(search[:term])
      end
      
      scope.order(:first_name, :last_name)
    end

    def orders
      current_merchant.orders.includes(:customer, :order_items => :product).order(created_at: :desc)
    end
    
    def order(id: nil, reference: nil)
      scope = current_merchant.orders.includes(:customer, :delivery_address, :order_items)
      
      if id
        scope.find_by(id: id)
      elsif reference
        scope.find_by(reference: reference)
      end
    end

    def shipping_options(input:)
      ShippingOptionsService.new(input[:delivery], input[:items]).available_options
    end

    def payment_options
      PaymentOptionsService.new.available_options
    end

    private

    def current_merchant
      # This should be set in the GraphQL context
      # For now, we'll return the first merchant for development
      context[:current_merchant] || Merchant.first
    end
  end
end