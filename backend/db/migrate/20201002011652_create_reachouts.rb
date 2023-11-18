class CreateReachouts < ActiveRecord::Migration[6.0]
  def change
    create_table :reachouts do |t|
      t.integer :user_id
      t.integer :contact_id
      t.string :frequency
      t.date :last_reachout_sent
      t.string :start_date
      t.string :datetime

      t.timestamps
    end
  end
end
