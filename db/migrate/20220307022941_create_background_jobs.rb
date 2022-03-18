class CreateBackgroundJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :background_jobs do |t|
      t.string :job_id
      t.string :status
      t.string :user_id
      t.string :work_created
      t.string :media_file

      t.timestamps
    end
  end
end
