class AddUploadHashToUploadedFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :uploaded_files, :upload_hash, :string
  end
end
