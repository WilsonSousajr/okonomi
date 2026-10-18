class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :projects, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Account creation rules (#2). has_secure_password already caps the password
  # at bcrypt's 72 bytes; the 8-character floor is the minimum policy.
  validates :email_address, presence: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true },
                            uniqueness: { case_sensitive: false, message: :already_registered }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
