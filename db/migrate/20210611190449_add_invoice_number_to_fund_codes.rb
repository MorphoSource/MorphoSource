class AddInvoiceNumberToFundCodes < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_codes, :invoice_number, :string
  end
end
