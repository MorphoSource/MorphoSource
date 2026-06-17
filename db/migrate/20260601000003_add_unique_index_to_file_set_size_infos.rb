class AddUniqueIndexToFileSetSizeInfos < ActiveRecord::Migration[6.1]
  def change
    remove_index :file_set_size_infos, :file_set_id
    add_index :file_set_size_infos, :file_set_id, unique: true
  end
end
