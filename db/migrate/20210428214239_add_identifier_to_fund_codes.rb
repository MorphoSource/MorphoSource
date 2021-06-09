class AddIdentifierToFundCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_codes, :identifier, :string
  end
end
