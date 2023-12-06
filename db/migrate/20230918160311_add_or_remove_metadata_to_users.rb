class AddOrRemoveMetadataToUsers < ActiveRecord::Migration[5.2]
  def up
    UsersMigrationHelper.add_user_columns
  end
  def down
    UsersMigrationHelper.remove_user_columns
  end
end
