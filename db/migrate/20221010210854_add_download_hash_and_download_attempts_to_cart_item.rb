class AddDownloadHashAndDownloadAttemptsToCartItem < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :download_hash, :string
    add_column :cart_items, :download_attempts, :integer
  end
end
