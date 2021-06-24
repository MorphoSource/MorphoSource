class AddDownloadUsageListToCartItem < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :download_usage_list, :string
  end
end
