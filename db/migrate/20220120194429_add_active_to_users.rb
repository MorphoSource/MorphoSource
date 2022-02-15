class AddActiveToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :active, :boolean, null: false, default: true
  end
end
