# frozen_string_literal: true

# Make end_time field non null
class MakeEventsEndTimeNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:events, :end_time, false)
  end
end
