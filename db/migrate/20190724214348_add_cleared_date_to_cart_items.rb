class AddClearedDateToCartItems < ActiveRecord::Migration[5.1]
  def change
    add_column :cart_items, :date_cleared, :datetime
  end
end
