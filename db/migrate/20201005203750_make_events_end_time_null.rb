class MakeEventsEndTimeNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:events, :end_time, false)
  end
end
