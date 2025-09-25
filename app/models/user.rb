class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true
  validates :firstName, presence: true
  validates :lastName, presence: true
  validates :role, presence: true, inclusion: { in: %w[admin staff] }
  
  def full_name
    "#{firstName} #{lastName}"
  end
end