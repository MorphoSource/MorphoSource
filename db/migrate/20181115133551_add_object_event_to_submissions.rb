class AddObjectEventToSubmissions < ActiveRecord::Migration[5.1]
  def change
    add_column :submissions, :object_id, :string
    add_column :submissions, :event_id, :string
  end
end
