class RemoveMainJobIdFromBackgroundJob < ActiveRecord::Migration[5.2]
  def change
    remove_column :background_jobs, :main_job_id, :string
  end
end
