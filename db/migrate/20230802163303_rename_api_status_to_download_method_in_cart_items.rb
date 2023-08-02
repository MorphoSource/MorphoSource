class RenameAPIStatusToDownloadMethodInCartItems < ActiveRecord::Migration[5.2]
  def change
    rename_column :cart_items, :api_status, :download_method
  end
end
