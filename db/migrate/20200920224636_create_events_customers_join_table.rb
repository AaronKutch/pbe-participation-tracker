# frozen_string_literal: true

class CreateEventsCustomersJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :customers, :events do |t|
      t.index %i[customer_id event_id], unique: true
      # t.index :event_id
    end
  end
end
