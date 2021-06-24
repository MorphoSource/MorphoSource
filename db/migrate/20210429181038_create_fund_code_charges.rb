class CreateFundCodeCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :fund_code_charges do |t|
      t.references :fund_code
      t.text :description
      t.date :start_date
      t.date :end_date
      t.decimal :billing_rate
      t.string :billing_unit
      t.decimal :units_consumed
      t.decimal :amount
      t.string :service_type

      t.timestamps
    end
  end
end
