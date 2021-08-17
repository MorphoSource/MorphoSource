class ChangeFundCodesStorageTotalGbFromFloatToDecimal < ActiveRecord::Migration[5.2]
  def change
  	change_column :fund_codes, :storage_total_gb, :decimal
  end
end
