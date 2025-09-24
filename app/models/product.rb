class Product < ApplicationRecord
  # Enums
  enum product_type: { physical: 0, digital: 1 }

  # Associations
  belongs_to :merchant
  belongs_to :product_category, optional: true
  has_many :order_items

  # Validations
  validates :name, presence: true
  validates :product_type, presence: true, inclusion: { in: product_types.keys }
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_category, ->(category_id) { where(product_category_id: category_id) if category_id.present? }
  scope :search, ->(term) { 
    if term.present?
      where("name ILIKE ? OR description ILIKE ?", "%#{term}%", "%#{term}%")
    end
  }

  # Instance methods
  def price
    Money.new(price_cents, currency)
  end

  def photo_url
    return super if super.present?
    
    # Return a default placeholder if no photo is set
    nil
  end

  def digital?
    product_type == 'digital'
  end

  def physical?
    product_type == 'physical'
  end

  private

  # Simple Money class for price formatting
  class Money
    attr_reader :cents, :currency

    def initialize(cents, currency = 'PHP')
      @cents = cents
      @currency = currency
    end

    def formatted
      case currency
      when 'PHP'
        "₱#{(cents / 100.0).round(2)}"
      else
        "#{currency} #{(cents / 100.0).round(2)}"
      end
    end
  end
end