class Customer < ApplicationRecord
  has_secure_password
  has_and_belongs_to_many :events

  attribute :role, :string, default: 'user'

  EMAIL_REGEX = /\A[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}\Z/i.freeze

  validates_presence_of :first_name, :last_name, :email, :password
  validates_length_of :first_name, maximum: 50
  validates_length_of :last_name, maximum: 50
  validates_length_of :email, maximum: 128
  validates_uniqueness_of :email
  validates_format_of :email, with: EMAIL_REGEX
end
