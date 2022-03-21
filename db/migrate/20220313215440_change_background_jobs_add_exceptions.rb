class ChangeBackgroundJobsAddExceptions < ActiveRecord::Migration[5.2]
  def change
    add_column :background_jobs, :main_job_id, :string
    add_column :background_jobs, :exceptions, :text
  end
end
