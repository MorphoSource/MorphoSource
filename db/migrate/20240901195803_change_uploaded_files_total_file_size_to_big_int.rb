class ChangeUploadedFilesTotalFileSizeToBigInt < ActiveRecord::Migration[5.2]
  def up 
    change_column :uploaded_files, :total_file_size, :bigint
  end
end
