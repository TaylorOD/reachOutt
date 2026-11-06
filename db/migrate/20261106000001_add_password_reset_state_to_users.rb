class AddPasswordResetStateToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :session_version, :integer, default: 0, null: false
    add_column :users, :password_reset_sent_at, :datetime
  end
end
