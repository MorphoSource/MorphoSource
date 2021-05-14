class AddChargeableToFundCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_codes, :chargeable, :boolean, :default => false, :null => false
  end
end
