class CreateScenes < ActiveRecord::Migration[5.2]
  def change
    create_table :scenes do |t|
      t.string :media_id, null: false
      t.jsonb :aleph_scene, null: false
      t.jsonb :iiif_annotations
      t.jsonb :iiif_transforms
    end
  end
end
