# lib/users_migration_helper.rb

module UsersMigrationHelper

  def self.fields
    yaml_data = YAML.load_file(Rails.root.join('config', 'models', 'user_metadata.yml'))
    yaml_data['user_metadata']
  end

  def self.add_user_columns
    self.fields.each do |field, data_type|
      unless ActiveRecord::Base.connection.column_exists?(:users, field)
        ActiveRecord::Migration.add_column :users, field, data_type
      end
    end
  end

  def self.remove_user_columns
    self.fields.each do |field, data_type|
      if ActiveRecord::Base.connection.column_exists?(:users, field)
        ActiveRecord::Migration.remove_column :users, field
      end
    end
  end

end
