class AddTurnPlayerToGame < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :turn_player_id, :integer
    add_column :games, :winner_player_id, :integer
    add_column :games, :board, :integer, array: true, default: []
    add_index :games, :turn_player_id
    add_index :games, :winner_player_id
  end
end
