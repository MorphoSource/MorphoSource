class AddMediaSizeHashToFundCodeCharges < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_code_charges, :media_size_hash, :text
  end
end
