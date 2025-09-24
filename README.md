# Rails POS Merchant Dashboard Backend

A GraphQL API backend for a Point of Sale (POS) merchant dashboard that allows merchants to manage products, customers, and orders with email notifications and image upload capabilities.

## Features

- **Product Management**: Create, update, delete products with categories and image upload to Cloudinary
- **Order Management**: Create orders (online/in-store), confirm, complete with complex business logic
- **Customer Management**: Search customers by email/phone with auto-fill from previous orders
- **Email Notifications**: Automatic order confirmation emails to customers
- **Shipping & Payment**: Integration with shipping and payment options services
- **Voucher System**: Discount codes with various types (percentage, fixed, free shipping)
- **GraphQL API**: Complete GraphQL schema with queries, mutations, and file uploads

## Tech Stack

- **Ruby**: 3.4.6
- **Rails**: 7.1.5+
- **Database**: PostgreSQL
- **API**: GraphQL (graphql-ruby)
- **Image Storage**: Cloudinary
- **Email**: ActionMailer with Letter Opener (development)
- **Background Jobs**: ActiveJob

## Setup

### Prerequisites

- Ruby 3.4.6
- PostgreSQL
- Bundler
- Cloudinary account (for image uploads)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd rails-pos-backend
```

2. Install dependencies:
```bash
bundle install
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Create and setup the database:
```bash
rails db:create
rails db:migrate
rails db:seed  # Optional: creates sample data
```

### Environment Variables

Create a `.env` file based on `.env.example`:

```env
# Database
DATABASE_URL=postgresql://username:password@localhost/rails_pos_development

# Cloudinary (required for image uploads)
CLOUDINARY_URL=cloudinary://api_key:api_secret@cloud_name
# OR individual credentials:
# CLOUDINARY_CLOUD_NAME=your_cloud_name
# CLOUDINARY_API_KEY=your_api_key
# CLOUDINARY_API_SECRET=your_api_secret

# Payment gateway (for payment links)
PAYMENT_GATEWAY_URL=https://payments.example.com
```

### Running the Application

```bash
rails server
```

The GraphQL endpoint will be available at:
- **API**: http://localhost:3000/graphql
- **GraphiQL IDE**: http://localhost:3000/graphiql (development only)
- **Email Preview**: http://localhost:3000/letter_opener (development only)

## GraphQL Schema

### Key Types

- `ProductCategory`: Product categories with position ordering
- `Product`: Products with pricing, images, and type (physical/digital)
- `Customer`: Customer information with search capabilities
- `Address`: Delivery addresses linked to customers
- `Order`: Orders with items, totals, shipping, and payment info
- `OrderItem`: Line items with product snapshots

### Main Queries

```graphql
# Get all product categories
productCategories

# Get products with filtering
products(filter: { categoryId: ID, search: String, active: Boolean })

# Search customers
customers(search: { email: String, phone: String, term: String })

# Get shipping options for address and items
shippingOptions(input: { delivery: DeliveryInput!, items: [OrderItemInput!]! })

# Get available payment options
paymentOptions
```

### Main Mutations

```graphql
# Product management
createProduct(input: CreateProductInput!)
updateProduct(id: ID!, input: UpdateProductInput!)
deleteProduct(id: ID!)

# Category management
createProductCategory(input: CreateProductCategoryInput!)
updateProductCategory(id: ID!, input: UpdateProductCategoryInput!)
deleteProductCategory(id: ID!)

# Order management
createOrder(input: CreateOrderInput!)
confirmOrder(id: ID!)
completeOrder(id: ID!)
```

### File Uploads

The API supports multipart file uploads for product images using the GraphQL multipart spec:

```
POST /graphql
Content-Type: multipart/form-data

operations: {"query": "mutation($input: CreateProductInput!) { ... }", "variables": {"input": {..., "photo": null}}}
map: {"0": ["variables.input.photo"]}
0: <file>
```

## Business Logic

### Order Creation

1. **Customer Handling**: Find existing customer by email or create new one
2. **Address Creation**: Create delivery address if provided
3. **Product Validation**: Ensure all products exist and are active
4. **Shipping Calculation**: Calculate shipping fees based on location and items
5. **Payment Processing**: Set convenience fees based on payment method
6. **Voucher Processing**: Apply discounts from valid voucher codes
7. **Email Notification**: Send order confirmation email to customer
8. **Payment Link**: Generate payment link for online payment methods

### Voucher System

Supported voucher types:
- **Percentage**: Percentage discount with optional maximum limit
- **Fixed**: Fixed amount discount
- **Shipping**: Free shipping discount

Sample vouchers (for testing):
- `WELCOME10`: 10% discount (min ₱500, max ₱200 discount)
- `FIRSTORDER`: ₱100 fixed discount (min ₱300)
- `FREESHIP`: Free shipping (min ₱1000)
- `SAVE50`: ₱50 fixed discount (no minimum)

### Order Status Flow

```
PENDING → CONFIRMED → COMPLETED
```

- **PENDING**: Initial state when order is created
- **CONFIRMED**: Merchant confirms the order
- **COMPLETED**: Order is fulfilled and completed

## Testing

Use the provided Postman collection in `docs/QA_POSTMAN.md` for comprehensive API testing.

Example test scenarios:
1. Create product categories
2. Create products with and without images
3. Search customers
4. Get shipping and payment options
5. Create orders (both online and in-store)
6. Confirm and complete orders

## Email Templates

Order confirmation emails include:
- Order reference and details
- Customer information
- Delivery address (if applicable)
- Order items with pricing
- Shipping and payment method
- Order summary with totals
- Payment link (for online payments)

## Services Architecture

### CloudinaryService
- Handles image uploads and deletions
- Automatic image optimization and transformation
- Organized folder structure by merchant

### PaymentLinkService
- Generates payment links for online orders
- Supports multiple payment gateways
- Configurable via environment variables

### ShippingOptionsService
- Calculates shipping options based on location
- Distance-based pricing (Metro Manila, Luzon, Visayas/Mindanao)
- Weight-based surcharges
- Free shipping eligibility

### VoucherService
- Validates and applies discount codes
- Supports multiple discount types
- Minimum order requirements

## Error Handling

All mutations return standardized error responses:

```graphql
type UserError {
  message: String!
  path: [String!]
}
```

Errors include:
- Validation errors from ActiveRecord
- Business logic violations
- File upload failures
- Authentication/authorization errors

## Security

- All operations are scoped to the current merchant
- File uploads are validated for type and size
- SQL injection prevention via ActiveRecord
- CORS configured for cross-origin requests

## Development Tools

- **GraphiQL**: Interactive GraphQL IDE at `/graphiql`
- **Letter Opener**: Email preview at `/letter_opener`
- **Rails Console**: Access via `rails console`
- **Database Console**: Access via `rails dbconsole`

## Deployment

Refer to `docs/DEPLOYMENT_RENDER.md` for deployment instructions to Render or other platforms.

## Contributing

1. Follow Rails conventions and best practices
2. Write tests for new functionality
3. Update documentation for API changes
4. Ensure proper error handling and validation

## License

This project is created for assessment purposes.
