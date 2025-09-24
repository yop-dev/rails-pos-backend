# GraphQL API Test Suite

Comprehensive test suite for the Rails POS GraphQL backend. Test these in Postman at `POST http://localhost:3000/graphql`.

## 1. Query Tests

### Test 1: Product Categories ✅
```json
{
  "query": "query { productCategories { id name position } }"
}
```

### Test 2: Products Query ✅
```json
{
  "query": "query { products { id name description priceCents currency productType active } }"
}
```

### Test 3: Products with Filter ✅
```json
{
  "query": "query($filter: ProductsFilterInput) { products(filter: $filter) { id name priceCents } }",
  "variables": {
    "filter": {
      "categoryId": "5",
      "active": true
    }
  }
}
```

### Test 4: Orders Query ✅
```json
{
  "query": "query { orders { id reference status totalCents createdAt } }"
}
```

### Test 5: Specific Order by ID ✅
```json
{
  "query": "query($id: ID!) { order(id: $id) { id reference status totalCents } }",
  "variables": {
    "id": "2"
  }
}
```

### Test 6: Customers Search
```json
{
  "query": "query($search: CustomersSearchInput!) { customers(search: $search) { id firstName lastName email } }",
  "variables": {
    "search": {
      "term": "john"
    }
  }
}
```

### Test 7: Payment Options ✅
```json
{
  "query": "query { paymentOptions { code label convenienceFeeCents } }"
}
```

### Test 8: Shipping Options ✅
```json
{
  "query": "query($input: ShippingOptionsInput!) { shippingOptions(input: $input) { code label feeCents } }",
  "variables": {
    "input": {
      "delivery": {
        "line1": "123 Main St",
        "city": "New York",
        "state": "NY",
        "postalCode": "10001",
        "country": "US"
      },
      "items": [
        {
          "productId": "12",
          "quantity": 2
        }
      ]
    }
  }
}
```

## 2. Mutation Tests

### Test 9: Create Product Category ✅
```json
{
  "query": "mutation($input: CreateCategoryInput!) { createCategory(input: $input) { category { id name position } errors { message } } }",
  "variables": {
    "input": {
      "name": "Test Category",
      "position": 5
    }
  }
}
```

### Test 10: Create Product ✅
```json
{
  "query": "mutation($input: CreateProductInput!) { createProduct(input: $input) { product { id name priceCents } errors { message } } }",
  "variables": {
    "input": {
      "input": {
        "name": "Test Product",
        "description": "A test product",
        "categoryId": "5",
        "priceCents": 1500,
        "currency": "USD",
        "productType": "PHYSICAL"
      }
    }
  }
}
```

### Test 11: Update Product ✅
```json
{
  "query": "mutation($input: UpdateProductInput!) { updateProduct(input: $input) { product { id name priceCents } errors { message } } }",
  "variables": {
    "input": {
      "id": "12",
      "input": {
        "name": "Updated Product Name",
        "priceCents": 2000
      }
    }
  }
}
```

### Test 12: Create Order ✅
```json
{
  "query": "mutation($input: CreateOrderInput!) { createOrder(input: $input) { order { id reference totalCents } errors { message } } }",
  "variables": {
    "input": {
      "input": {
        "source": "IN_STORE",
        "items": [
          {
            "productId": "12",
            "quantity": 2
          }
        ],
        "customer": {
          "firstName": "John",
          "lastName": "Doe",
          "email": "john.doe@example.com",
          "phone": "555-1234"
        },
        "paymentMethodCode": "cash"
      }
    }
  }
}
```

### Test 13: Confirm Order ✅
```json
{
  "query": "mutation($input: ConfirmOrderInput!) { confirmOrder(input: $input) { order { id reference status totalCents } errors { message } } }",
  "variables": {
    "input": {
      "id": "2"
    }
  }
}
```

## 3. Error Handling Tests

### Test 14: Invalid Query (Should return error) ✅
```json
{
  "query": "query { nonExistentField }"
}
```

### Test 15: Missing Required Arguments ✅
```json
{
  "query": "query { customers { id firstName } }"
}
```

### Test 16: Invalid Input Types ✅
```json
{
  "query": "mutation($input: CreateCategoryInput!) { createCategory(input: $input) { category { id name position } errors { message } } }",
  "variables": {
    "input": {
      "name": "Test Category",
      "position": 5
    }
  }
}
```

## 4. Schema Introspection Tests

### Test 17: Schema Types ✅
```json
{
  "query": "query { __schema { types { name kind } } }"
}
```

### Test 18: Available Queries ✅
```json
{
  "query": "query { __schema { queryType { fields { name type { name } } } } }"
}
```

### Test 19: Available Mutations ✅
```json
{
  "query": "query { __schema { mutationType { fields { name type { name } } } } }"
}
```

### Test 20: Specific Type Introspection ✅
```json
{
  "query": "query { __type(name: \"ProductsFilterInput\") { name inputFields { name type { name } } } }"
}
```

## Field Name Conventions

### Output Fields (camelCase)
- `price_cents` → `priceCents`
- `product_type` → `productType`
- `total_cents` → `totalCents`
- `created_at` → `createdAt`
- `updated_at` → `updatedAt`
- `first_name` → `firstName`
- `last_name` → `lastName`
- `shipping_options` → `shippingOptions`
- `payment_options` → `paymentOptions`
- `amount_cents` → `amountCents`

### Input Fields (camelCase)
- `category_id` → `categoryId`
- `product_id` → `productId`
- `price_cents` → `priceCents`
- `product_type` → `productType`
- `unit_price_cents` → `unitPriceCents`
- `payment_method_code` → `paymentMethodCode`
- `order_id` → `orderId`
- `amount_cents` → `amountCents`
- `postal_code` → `postalCode`

## Expected Results

| Test Range | Expected Outcome |
|------------|------------------|
| Tests 1-8  | Should return data or empty arrays (no errors) |
| Tests 9-13 | Should create/update records and return success responses |
| Tests 14-16| Should return GraphQL errors with helpful messages |
| Tests 17-20| Should return schema information |

## Status Indicators

- ✅ **Success**: Data returned without errors
- ❌ **Failure**: Error messages in the response
- ⚠️ **Warning**: Empty data (might indicate no records exist)
- 🔧 **Needs Setup**: Requires database records to test properly

## Notes

1. Some tests may return empty arrays if no data exists in the database
2. Mutation tests will create actual records in your database
3. Use Test 17-20 for debugging field name issues
4. All field names follow GraphQL camelCase convention
5. Input arguments use camelCase but maintain logical snake_case in Ruby code

## Troubleshooting

If you encounter field name errors:
1. Run Test 20 with the problematic type name
2. Check the actual field names returned
3. Update your queries to match the schema

If you encounter missing type errors:
1. Check that all input types are created in `app/graphql/types/`
2. Restart the Rails server to load new types
3. Verify the type is properly referenced in mutations/queries