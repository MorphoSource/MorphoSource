class AddApprovedByToCartItems < ActiveRecord::Migration[5.1]
  def change
    add_column :cart_items, :action_by, :string
  end
end
