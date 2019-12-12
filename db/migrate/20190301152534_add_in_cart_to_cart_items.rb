class AddInCartToCartItems < ActiveRecord::Migration[5.1]
  def change
    add_column :cart_items, :in_cart, :boolean, default: true
  end
end
