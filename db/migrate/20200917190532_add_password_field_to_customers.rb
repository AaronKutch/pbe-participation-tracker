# frozen_string_literal: true

# Add proper password field to customer model
class AddPasswordFieldToCustomers < ActiveRecord::Migration[6.0]
  def change
    remove_column 'customers', 'password', :string
    add_column 'customers', 'password_digest', :string, null: false
  end
end
