class Customer < ApplicationRecord
    has_secure_password
    has_and_belongs_to_many :events
end
