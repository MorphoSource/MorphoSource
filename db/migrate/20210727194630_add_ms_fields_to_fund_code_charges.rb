class AddMsFieldsToFundCodeCharges < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_code_charges, :fund_code_remaining, :decimal
  end
end
