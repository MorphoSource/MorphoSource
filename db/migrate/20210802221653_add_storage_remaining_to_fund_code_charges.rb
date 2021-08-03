class AddStorageRemainingToFundCodeCharges < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_code_charges, :fund_code_storage_remaining_gb, :decimal
  end
end
