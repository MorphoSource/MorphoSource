class AddTotalRemainingToFundCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_codes, :total, :decimal
    add_column :fund_codes, :remaining, :decimal
  end
end
