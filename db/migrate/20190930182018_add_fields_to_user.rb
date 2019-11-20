class AddFieldsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :state, :string
    add_column :users, :country, :string
    add_column :users, :postal_code, :string
    add_column :users, :terms_read, :boolean, default: false
    add_column :users, :demographics, :string
    add_column :users, :intent, :text
    add_column :users, :status, :string
    add_column :users, :software, :string
    add_column :users, :mesh_file_type, :string
    add_column :users, :volume_file_type, :string
    add_column :users, :printer_model, :string
    add_column :users, :printer_file, :string

    remove_column :users, :googleplus_handle
    remove_column :users, :title
    remove_column :users, :office
    remove_column :users, :admin_area
    remove_column :users, :chat_id
    remove_column :users, :linkedin_handle     
  end
end
