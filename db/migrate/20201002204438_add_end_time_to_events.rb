# frozen_string_literal: true

# Add end_time field to event model
class AddEndTimeToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column 'events', 'end_time', :datetime
  end
end
