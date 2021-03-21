class CreateFundCodeMediaAssociations < ActiveRecord::Migration[5.2]
  def change
    create_table :fund_code_media_associations do |t|
      t.references :fund_code, foreign_key: true
      t.string :media, null: false
      t.boolean :active, null: false

      t.timestamps
    end
  end
end
