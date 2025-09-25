# Quick Email Testing in Rails Console

## Method 1: Run the Test Script

```bash
ruby test_email_development.rb
```

## Method 2: Rails Console Testing

```bash
rails console
```

Then run these commands one by one:

### Test Environment Variables
```ruby
# Check if Maileroo credentials are loaded
puts "API Key: #{ENV['MAILEROO_API_KEY'] ? 'SET' : 'NOT SET'}"
puts "SMTP Email: #{ENV['MAILEROO_SMTP_EMAIL']}"
puts "From Name: #{ENV['MAILEROO_FROM_NAME']}"
```

### Test Maileroo API Service
```ruby
# Test the Maileroo API connection
maileroo = MailerooService.new
account_info = maileroo.get_account_info
puts account_info
```

### Send Test Email via API
```ruby
# Send test email via Maileroo API
result = maileroo.send_email(
  to: 'desilvajoner95@gmail.com',  # Your email
  subject: 'Test from Rails POS Development',
  html_content: '<h1>Hello!</h1><p>This is a test email from Rails POS development environment.</p>'
)
puts result
```

### Test SMTP Configuration
```ruby
# Check ActionMailer SMTP settings
puts Rails.application.config.action_mailer.smtp_settings
```

### Send Test Email via ActionMailer SMTP
```ruby
# Send test email via Rails ActionMailer + Maileroo SMTP
test_mail = ActionMailer::Base.mail(
  from: 'rails-pos@railspos.maileroo.app',
  to: 'desilvajoner95@gmail.com',
  subject: 'ActionMailer + Maileroo SMTP Test',
  body: 'This email was sent via ActionMailer using Maileroo SMTP.'
)

test_mail.deliver_now
```

### Test OrderMailer (if you have orders)
```ruby
# Find an order to test with
order = Order.first

if order
  # Send order confirmation email
  OrderMailer.order_placed(order).deliver_now
  puts "Order email sent to: #{order.customer.email}"
else
  puts "No orders found. Create an order first or create test data."
end
```

## Method 3: Create Test Order Data

If you don't have any orders, you can create test data:

```ruby
# In Rails console - create test data for email testing
merchant = Merchant.first || Merchant.create!(
  name: 'Test Store',
  email: 'store@example.com',
  phone: '123-456-7890'
)

customer = Customer.create!(
  first_name: 'John',
  last_name: 'Doe',
  email: 'desilvajoner95@gmail.com',  # Your email to receive test
  phone: '098-765-4321'
)

category = ProductCategory.first || ProductCategory.create!(
  name: 'Test Category',
  merchant: merchant
)

product = Product.first || Product.create!(
  name: 'Test Product',
  description: 'Test product for email testing',
  price_cents: 1000,  # $10.00
  product_category: category,
  merchant: merchant
)

order = Order.create!(
  reference: 'TEST-' + SecureRandom.hex(4).upcase,
  customer: customer,
  merchant: merchant,
  order_type: 'ONLINE',
  payment_method: 'CREDIT_CARD',
  shipping_method: 'DELIVERY',
  subtotal_cents: 1000,
  shipping_fee_cents: 500,
  convenience_fee_cents: 100,
  total_cents: 1600,
  payment_link: 'https://example.com/pay',
  status: 'PENDING'
)

OrderItem.create!(
  order: order,
  product: product,
  product_name: product.name,
  quantity: 1,
  unit_price_cents: 1000,
  total_price_cents: 1000
)

# Now test the email
OrderMailer.order_placed(order).deliver_now
puts "Test order email sent!"
```

## Troubleshooting

If emails aren't being sent, check:

1. **Environment Variables**: Make sure your .env file is loaded
2. **Network Connection**: Ensure you can reach smtp.maileroo.com
3. **Credentials**: Verify your Maileroo credentials are correct
4. **Spam Folder**: Check your spam/junk folder
5. **Maileroo Dashboard**: Check delivery logs at maileroo.com

## Expected Results

You should receive test emails at: `desilvajoner95@gmail.com`

The emails will come from: `rails-pos@railspos.maileroo.app`