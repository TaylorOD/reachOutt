class AddReminderSchedule < ActiveRecord::Migration[8.1]
  def up
    add_column :reachouts, :next_send_at, :datetime
    add_index :reachouts, :next_send_at
    add_index :reachouts, :user_id
    add_index :reachouts, :contact_id
    add_index :contacts, :user_id

    # Invalid legacy schedules stay paused until their owner edits them.
    record = Class.new(ActiveRecord::Base) { self.table_name = 'reachouts' }
    record.reset_column_information
    record.find_each do |reachout|
      next unless %w[1d 7d 14d 30d 60d 90d 182.5d 365d].include?(reachout.frequency)
      begin
        date = Date.iso8601(reachout.start_date.to_s)
        reachout.update_columns(next_send_at: [date.in_time_zone, Time.current].max)
      rescue ArgumentError
        next
      end
    end
  end

  def down
    remove_index :contacts, :user_id
    remove_index :reachouts, :contact_id
    remove_index :reachouts, :user_id
    remove_column :reachouts, :next_send_at
  end
end
