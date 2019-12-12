class CreateCartItems < ActiveRecord::Migration[5.1]
  def change
    create_table :cart_items do |t|
      t.integer :media_cart_id, null: false
      t.string :work_id, null: false
      t.boolean :downloaded, default: false
      t.index :media_cart_id
      t.index :work_id
      t.timestamps
    end
  end
end
