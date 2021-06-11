class AddDownloadUsageToCartItem < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :download_usage, :string
  end
end
