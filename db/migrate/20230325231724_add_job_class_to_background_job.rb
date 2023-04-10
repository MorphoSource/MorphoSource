class AddJobClassToBackgroundJob < ActiveRecord::Migration[5.2]
  def change
    add_column :background_jobs, :job_class, :string
  end
end
