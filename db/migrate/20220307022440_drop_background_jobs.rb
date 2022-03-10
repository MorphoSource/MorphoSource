class DropBackgroundJobs < ActiveRecord::Migration[5.2]
  def up
    drop_table :background_jobs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
