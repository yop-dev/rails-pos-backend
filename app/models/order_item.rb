class OrderItem < ApplicationRecord
  # Associations
  belongs_to :order
  belongs_to :product

  # Validations
  validates :product_name_snapshot, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_save :set_product_snapshot
  before_save :calculate_total_price

  # Instance methods
  def unit_price
    Product::Money.new(unit_price_cents, "PHP")
  end

  def total_price
    Product::Money.new(total_price_cents, "PHP")
  end

  def product_name
    product_name_snapshot
  end

  private

  def set_product_snapshot
    self.product_name_snapshot = product.name if product_name_snapshot.blank?
  end

  def calculate_total_price
    self.total_price_cents = unit_price_cents * quantity
  end
end