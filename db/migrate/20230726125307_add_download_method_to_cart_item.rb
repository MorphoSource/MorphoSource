class AddDownloadMethodToCartItem < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :download_method, :string
  end
end
