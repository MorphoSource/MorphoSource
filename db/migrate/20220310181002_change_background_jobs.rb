class ChangeBackgroundJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :background_jobs, :created_objects, :json, default: {}
  end
end
