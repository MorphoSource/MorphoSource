class AddUserIndexToCartItems < ActiveRecord::Migration[5.1]
  def change
    add_index :cart_items, :user_id
  end
end
