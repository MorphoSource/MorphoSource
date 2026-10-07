class CreateFileSetSizeInfos < ActiveRecord::Migration[6.1]
  def change
    create_table :file_set_size_infos do |t|
      t.string  :file_set_id, null: false
      t.string  :media_id
      t.references :data_allocation, foreign_key: true, null: true
      t.bigint  :sum_file_size,                 null: false, default: 0
      t.string  :binary_file_name
      t.bigint  :binary_file_size,              null: false, default: 0
      t.bigint  :summed_derivatives_file_size,  null: false, default: 0
      t.json    :derivatives
      t.timestamps
    end

    add_index :file_set_size_infos, :file_set_id
  end
end
