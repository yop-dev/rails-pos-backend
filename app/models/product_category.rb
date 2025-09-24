class ProductCategory < ApplicationRecord
  # Associations
  belongs_to :merchant
  has_many :products, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, uniqueness: { scope: :merchant_id }
  validates :position, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :ordered, -> { order(:position, :name) }

  # Instance methods
  def products_count
    products.count
  end
end