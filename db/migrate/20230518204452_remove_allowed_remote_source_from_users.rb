class RemoveAllowedRemoteSourceFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :allowed_remote_source, :string
  end
end
