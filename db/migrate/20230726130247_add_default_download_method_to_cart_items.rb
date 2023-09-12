class AddDefaultDownloadMethodToCartItems < ActiveRecord::Migration[5.2]
  def change
    change_column :cart_items, :download_method, :string, default: "UI"
  end
end
