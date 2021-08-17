class RenameStorageLimitTbToStorageTotalGb < ActiveRecord::Migration[5.2]
  def change
  	rename_column :fund_codes, :storage_limit_tb, :storage_total_gb
  end
end
