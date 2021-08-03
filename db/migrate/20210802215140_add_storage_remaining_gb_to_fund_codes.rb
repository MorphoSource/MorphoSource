class AddStorageRemainingGbToFundCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_codes, :storage_remaining_gb, :decimal
  end
end
