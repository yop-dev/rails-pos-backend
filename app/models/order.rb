class Order < ApplicationRecord
  # Enums
  enum source: { online: 0, in_store: 1 }
  enum status: { pending: 0, confirmed: 1, completed: 2 }

  # Associations
  belongs_to :merchant
  belongs_to :customer
  belongs_to :delivery_address, class_name: "Address", optional: true
  has_many :order_items, dependent: :destroy

  # Attributes
  attr_accessor :skip_calculate_totals, :skip_total_validation

  # Validations
  validates :reference, presence: true, uniqueness: true
  validates :source, presence: true
  validates :status, presence: true
  validates :subtotal_cents, :shipping_fee_cents, :convenience_fee_cents, 
            :discount_cents, :total_cents, numericality: { greater_than_or_equal_to: 0 }
  
  validate :delivery_address_required_for_online_physical_orders
  validate :total_cents_calculation

  # Callbacks
  before_create :generate_reference
  before_save :calculate_totals, unless: :skip_calculate_totals
  after_create :send_order_placed_email

  # Scopes
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def subtotal
    Product::Money.new(subtotal_cents, "PHP")
  end

  def shipping_fee
    Product::Money.new(shipping_fee_cents, "PHP")
  end

  def convenience_fee
    Product::Money.new(convenience_fee_cents, "PHP")
  end

  def discount
    Product::Money.new(discount_cents, "PHP")
  end

  def total
    Product::Money.new(total_cents, "PHP")
  end

  def can_confirm?
    pending?
  end

  def can_complete?
    confirmed?
  end

  def confirm!
    return false unless can_confirm?
    
    update!(
      status: :confirmed, 
      confirmed_at: Time.current
    )
  end

  def complete!
    return false unless can_complete?
    
    update!(
      status: :completed, 
      completed_at: Time.current
    )
  end

  def all_items_digital?
    order_items.joins(:product).where(products: { product_type: 0 }).empty?
  end

  def requires_delivery?
    online? && !all_items_digital?
  end

  private

  def generate_reference
    return if reference.present?
    
    loop do
      candidate = "ORD-#{Date.current.strftime('%Y%m%d')}-#{SecureRandom.hex(3).upcase}"
      break self.reference = candidate unless Order.exists?(reference: candidate)
    end
  end

  def calculate_totals
    # Calculate subtotal from order items
    if order_items.loaded?
      self.subtotal_cents = order_items.sum(&:total_price_cents)
    else
      self.subtotal_cents = order_items.sum(:total_price_cents)
    end
    
    # Apply discount if voucher is present
    if voucher_code.present?
      begin
        discount_amount = VoucherService.new(self, voucher_code).compute_discount
        self.discount_cents = discount_amount
      rescue => e
        Rails.logger.error "Voucher calculation failed: #{e.message}"
        self.discount_cents = 0
      end
    else
      self.discount_cents = 0
    end

    # Calculate total: subtotal + shipping + convenience - discount
    self.total_cents = subtotal_cents + shipping_fee_cents + convenience_fee_cents - discount_cents
  end

  def delivery_address_required_for_online_physical_orders
    if requires_delivery? && delivery_address.nil?
      errors.add(:delivery_address, "is required for online orders with physical products")
    end
  end

  def total_cents_calculation
    return if skip_total_validation
    
    expected_total = subtotal_cents + shipping_fee_cents + convenience_fee_cents - discount_cents
    if total_cents != expected_total
      errors.add(:total_cents, "must equal subtotal + shipping fee + convenience fee - discount")
    end
  end

  def send_order_placed_email
    OrderMailer.order_placed(self).deliver_later
  end
end