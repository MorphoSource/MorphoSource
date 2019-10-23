class AddMsIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :ms_id, :string
    change_column_null :users, :ms_id, false, :temp_ms_id
    add_index :users, :ms_id
  end
end
