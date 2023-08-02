class RenameDownloadMethodColumnToAPIStatusInCartItems < ActiveRecord::Migration[5.2]
  def change
    rename_column :cart_items, :download_method, :api_status
    change_column_default :cart_items, :api_status, nil
  end
end
