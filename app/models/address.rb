class Address < ApplicationRecord
  # Associations
  belongs_to :customer
  has_many :orders_as_delivery, class_name: "Order", foreign_key: :delivery_address_id

  # Validations
  validates :street, presence: true
  validates :barangay, presence: true
  validates :city, presence: true
  validates :province, presence: true

  # Instance methods
  def full_address
    parts = []
    parts << unit_floor_building if unit_floor_building.present?
    parts << street
    parts << barangay
    parts << city
    parts << province
    parts << postal_code if postal_code.present?
    
    parts.join(", ")
  end

  def display_address
    address_parts = [
      unit_floor_building,
      street,
      barangay,
      city,
      province
    ].compact.reject(&:blank?)
    
    address_parts.join(", ")
  end
end