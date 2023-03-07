class CreateTemporaryCollectionAccessLink < ActiveRecord::Migration[5.2]
  def change
    create_table :temporary_collection_access_links do |t|
      t.references :user, foreign_key: true, null: false
      t.string :collection_id, null: false
      t.string :token, null: false, index: { unique: true }
      t.datetime :created_at, null: false
      t.datetime :expires_at, null: false
    end
  end
end
