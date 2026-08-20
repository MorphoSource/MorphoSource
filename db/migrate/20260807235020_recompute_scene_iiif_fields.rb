class RecomputeSceneIiifFields < ActiveRecord::Migration[6.1]
  # Uses the live Scene model, not a frozen snapshot, so existing rows get
  # iiif_annotations/iiif_cameras/iiif_transforms recomputed from aleph_scene
  # with whatever conversion logic is current as of this deploy.
  def up
    total = Scene.count
    say "Scenes to recompute: #{total}"

    recomputed = 0
    Scene.find_each do |scene|
      scene.save!
      recomputed += 1
    end

    say "Scenes recomputed: #{recomputed}"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
