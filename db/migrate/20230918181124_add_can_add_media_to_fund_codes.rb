class AddCanAddMediaToFundCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_codes, :can_add_media, :boolean, default: true, null: false
  end
end
