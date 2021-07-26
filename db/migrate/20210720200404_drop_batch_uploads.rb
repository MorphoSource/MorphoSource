class DropBatchUploads < ActiveRecord::Migration[5.2]
  def up
    drop_table :batch_uploads
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
