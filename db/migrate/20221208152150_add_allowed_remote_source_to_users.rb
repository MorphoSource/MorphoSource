class AddAllowedRemoteSourceToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :allowed_remote_source, :text
  end
end
