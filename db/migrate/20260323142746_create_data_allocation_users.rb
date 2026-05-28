class CreateDataAllocationUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :data_allocation_users do |t|
      t.references :data_allocation, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.timestamps
    end
  end
end
