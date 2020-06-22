class AddMs1PasswordHashToUsers < ActiveRecord::Migration[5.1]
  def change
  	add_column :users, :ms1_password_hash, :string
  end
end
