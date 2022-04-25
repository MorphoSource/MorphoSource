class ChangeBackgroundJobsDropColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :background_jobs, :work_created
    remove_column :background_jobs, :media_file
  end
end
