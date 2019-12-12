class RemoveDownloadedFromCartItems < ActiveRecord::Migration[5.1]
  def change
    remove_column :cart_items, :downloaded, :boolean
  end
end
