class AddIiifCamerasToScenes < ActiveRecord::Migration[6.1]
  def change
    add_column :scenes, :iiif_cameras, :jsonb
  end
end
