class NameFromPlayersToUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :players, :name
    add_column :users, :name, :string
  end
end
