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
    field :all_customers, [Types::CustomerType], null: false,
          description: "Get all customers for dropdown (no search required)" do
      argument :limit, Integer, required: false, description: "Limit number of results (default: 100)"
    end
    
    field :customers, [Types::CustomerType], null: false,
          description: "Search for customers" do
      argument :search, Types::CustomersSearchInput, required: false
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
    
    def all_customers(limit: 100)
      current_merchant.customers
                     .order(:first_name, :last_name)
                     .limit(limit)
    end

    def customers(search: nil, first: nil, after: nil)
      start_time = Time.current
      scope = current_merchant.customers
      search_type = 'all'
      search_value = nil
      
      # If search is provided and has values, filter accordingly
      if search.present?
        if search[:email].present?
          search_type = 'email'
          search_value = search[:email]
          scope = scope.search_by_email(search[:email])
        elsif search[:phone].present?
          search_type = 'phone'
          search_value = search[:phone]
          scope = scope.search_by_phone(search[:phone])
        elsif search[:term].present?
          search_type = 'term'
          search_value = search[:term]
          scope = scope.search_by_term(search[:term])
        end
      end
      
      # If no search provided or search had no values, return all customers (limited)
      results = scope.order(:first_name, :last_name).limit(first || 100)
      end_time = Time.current
      duration = (end_time - start_time) * 1000 # Convert to milliseconds
      
      # Log slow queries (> 500ms) for monitoring
      if duration > 500
        Rails.logger.warn(
          "[SLOW_CUSTOMER_SEARCH] Duration: #{duration.round(2)}ms, " +
          "Type: #{search_type}, Value: #{search_value&.truncate(50)}, " +
          "Results: #{results.count}, Merchant: #{current_merchant.id}"
        )
      end
      
      # Log all searches in development for debugging
      if Rails.env.development?
        Rails.logger.info(
          "[CUSTOMER_SEARCH] Duration: #{duration.round(2)}ms, " +
          "Type: #{search_type}, Value: #{search_value&.truncate(50)}, " +
          "Results: #{results.count}"
        )
      end
      
      results
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