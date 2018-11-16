class RenameEventIdToImagingEventId < ActiveRecord::Migration[5.1]
  def change
    rename_column :submissions, :event_id, :imaging_event_id
  end
end
