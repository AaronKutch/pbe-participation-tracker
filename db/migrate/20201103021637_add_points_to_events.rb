# frozen_string_literal: true

# Adds point column to events to PBE Point Tracker
class AddPointsToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :points, :integer, default: 0
  end
end
