class RemoveSocialMediaHandlesFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :social_media_handles, :string
  end
end
