class DropSubmission < ActiveRecord::Migration[5.1]
  def change
    drop_table :submissions do |t|
      t.string "institution_id"
      t.string "object_id"
      t.string "imaging_event_id"
    end
  end
end
