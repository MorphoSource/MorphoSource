class AddUpdateProfileTokenAndSentAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :update_profile_token, :string
    add_column :users, :update_profile_sent_at, :datetime
  end
end
