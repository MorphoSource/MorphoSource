class AddAttachmentsToFundCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_codes, :attachments, :json
  end
end
