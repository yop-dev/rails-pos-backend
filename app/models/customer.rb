class Customer < ApplicationRecord
  # Associations
  belongs_to :merchant
  has_many :addresses, dependent: :destroy
  has_many :orders

  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { scope: :merchant_id }
  validates :first_name, presence: true
  validates :last_name, presence: true

  # Scopes
  scope :search_by_email, ->(email) { where("email ILIKE ?", "%#{email}%") if email.present? }
  scope :search_by_phone, ->(phone) { where("phone ILIKE ?", "%#{phone}%") if phone.present? }
  scope :search_by_term, ->(term) {
    if term.present?
      where("email ILIKE ? OR phone ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?", 
            "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%")
    end
  }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def default_address
    addresses.first
  end

  def last_checkout_address
    # Get the delivery address from the most recent order
    orders.joins(:delivery_address)
          .order(created_at: :desc)
          .first&.delivery_address
  end
end