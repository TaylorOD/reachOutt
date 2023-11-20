class AddTopicToReachoutt < ActiveRecord::Migration[6.0]
  def change
    add_column :reachouts, :topic, :string  
  end
end
