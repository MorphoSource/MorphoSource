class RemoveMediaCartReferences < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :media_cart_id, :integer
    remove_column :cart_items, :media_cart_id, :integer
    add_column :cart_items, :user_id, :integer
  end
end
