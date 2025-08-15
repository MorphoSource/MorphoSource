class AddDataToBackgroundJobs < ActiveRecord::Migration[6.1]
  def change
    add_column :background_jobs, :data, :jsonb, default: {}
  end
end
