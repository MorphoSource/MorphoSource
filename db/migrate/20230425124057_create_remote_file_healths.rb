class CreateRemoteFileHealths < ActiveRecord::Migration[5.2]
  def change
    create_table :remote_file_healths do |t|
      t.string :media
      t.string :status
      t.text :details

      t.timestamps
    end
  end
end
