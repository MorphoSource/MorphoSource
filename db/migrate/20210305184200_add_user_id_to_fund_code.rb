class AddUserIdToFundCode < ActiveRecord::Migration[5.2]
  def change
    add_reference :fund_codes, :user, foreign_key: true
  end
end
