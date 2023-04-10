class AddUserIndexToBackgroundJobs < ActiveRecord::Migration[5.2]
  def change
    add_index :background_jobs, :user_id
  end
end
