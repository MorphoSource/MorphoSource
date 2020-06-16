class UpdateCartItems < ActiveRecord::Migration[5.1]
  def up
    remove_column :cart_items, :approver_id
    remove_column :cart_items, :restricted
  end

  def down
    add_column :cart_items, :approver_id, :string
    remove_column :cart_items, :restricted, :boolean, null: false
  end
end
