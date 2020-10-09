# frozen_string_literal: true

# Create initial event table
class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :title, limit: 50, null: false
      t.text :description
      t.datetime :date, null: false
      t.string :location, limit: 128
      t.boolean :mandatory

      t.timestamps
    end
  end
end
