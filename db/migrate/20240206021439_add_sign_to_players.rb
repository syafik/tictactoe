class AddSignToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :sign, :string
  end
end
