# frozen_string_literal: true

class CreateCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers do |t|
      t.string 'first_name', limit: 50, null: false
      t.string 'last_name', limit: 50, null: false
      t.string 'email', null: false, limit: 128, unique: true, null: false
      t.string 'password', null: false
      t.string 'role', null: false
      t.timestamps
    end
  end
end
