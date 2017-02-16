class User < ActiveRecord::Base
  validates :login, presence: true, length: { maximum: 50, minimum: 4 }, uniqueness: { case_sensitive: false }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :first_name, length: { maximum: 50 }
  validates :middle_name, length: { maximum: 50 }
  has_secure_password
  validates :password, presence: true, length: { minimum: 4 }
end
