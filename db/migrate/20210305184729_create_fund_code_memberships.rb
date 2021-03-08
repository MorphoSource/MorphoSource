class CreateFundCodeMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :fund_code_memberships do |t|
      t.references :fund_code, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :manager, :null => false

      t.timestamps
    end
  end
end
