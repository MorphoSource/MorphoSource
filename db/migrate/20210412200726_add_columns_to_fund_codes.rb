class AddColumnsToFundCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_codes, :expires_at, :datetime
    add_column :fund_codes, :storage_limit_tb, :float
    add_column :fund_codes, :external_user, :boolean, :default => false, :null => false
    add_column :fund_codes, :external_user_additional_rate_percent, :float
  end
end
