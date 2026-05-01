class AddSkipAuthorizationToOauthApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :oauth_applications, :skip_authorization, :boolean, default: false, null: false
  end
end
