class AddTotalFileSizeToUploadedFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :uploaded_files, :total_file_size, :int, limit: 8
  end
end
