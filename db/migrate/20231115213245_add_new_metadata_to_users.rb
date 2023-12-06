class AddNewMetadataToUsers < ActiveRecord::Migration[5.2]

  def up
    metadata_fields.each do |field, data_type|
      unless column_exists?(:users, field)
        add_column :users, field, data_type
      end
    end
  end

  def down
    metadata_fields.each do |field, data_type|
      if column_exists?(:users, field)
        remove_column :users, field
      end
    end
  end

  def metadata_fields
    yaml_data = YAML.load_file(Rails.root.join('config', 'models', 'user_metadata.yml'))
    yaml_data['user_metadata']
  end

end
