class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.integer :user_id
      t.integer :game_id
      t.string :name

      t.timestamps
    end
  end
end
