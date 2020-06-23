class AddMs1UserToUsers < ActiveRecord::Migration[5.1]
  def change
  	add_column :users, :ms1_user, :boolean, default: false
  end
end
