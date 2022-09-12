class CreateTemporaryMediaLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :temporary_media_links do |t|
      t.references :user, foreign_key: true, null: false
      t.string :media_id, null: false
      t.string :token, null: false, index: { unique: true }
      t.datetime :created_at, null: false
      t.datetime :expires_at, null: false
    end
  end
end
