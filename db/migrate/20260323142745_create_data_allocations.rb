class CreateDataAllocations < ActiveRecord::Migration[6.1]
  def change
    create_table :data_allocations do |t|
      t.integer  :allocation_type, null: false
      t.decimal  :storage_total_gb
      t.decimal  :storage_current_gb, null: false, default: 0
      t.references :fund_code, foreign_key: true, null: true
      t.timestamps
    end
  end
end
