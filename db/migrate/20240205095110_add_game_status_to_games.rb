class AddGameStatusToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :status, :integer, default: 0
    add_index :games, :user_id
  end
end
