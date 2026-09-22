# Scene configuration and content for presenting media in Aleph or other IIIF 3D viewer
#
# == Schema Information
#
# Table name: scenes
#
#  id                 :bigint           not null, primary key
#  media_id           :string(255)      not null
#  aleph_scene        :jsonb            not null
#  iiif_annotations   :jsonb
#  iiif_transforms    :jsonb
#  iiif_cameras       :jsonb
class Scene < ApplicationRecord
  # Validations
  validates :media_id, presence: true, uniqueness: true
  validates :aleph_scene, presence: true
  validate :is_aleph_scene_hash_or_array?

  # Callbacks
  before_save :ensure_media_id_uniqueness, :set_iiif_annotations, :set_iiif_cameras, :set_iiif_transforms
  before_validation :parse_aleph_scene_to_json

  # Instance methods

  private

  def ensure_media_id_uniqueness
    if media_id_changed?
      existing_scene = Scene.find_by(media_id: media_id)
      if existing_scene && existing_scene.id != id
        errors.add(:media_id, "must be unique")
        throw(:abort)
      end
    end
  end

  def is_aleph_scene_hash_or_array?
    unless aleph_scene.is_a?(Hash) || aleph_scene.is_a?(Array)
      errors.add(:aleph_scene, "must be a valid JSON object (hash) or array")
    end
  end

  def parse_aleph_scene_to_json
    if aleph_scene.is_a?(String)
      begin
        self.aleph_scene = JSON.parse(aleph_scene)
      rescue JSON::ParserError
        errors.add(:aleph_scene, "must be valid JSON")
      end
    end
  end

  def set_iiif_annotations
    if aleph_scene_annotations.present?
      self.iiif_annotations = aleph_scene_annotations.map.with_index do |annotation, index|
        anno_iiif = {
          id: anno_uri(index),
          type: "Annotation",
          motivation: ["commenting"],
          bodyValue: annotation['label'] || "No Label"
        }
        if annotation['description'].present? && annotation['description'].is_a?(String)
          anno_iiif[:summary] = { "none": [ annotation['description'] ] }
        end

        anno_iiif[:target] = comment_target(annotation)

        # Link to the sibling camera annotation (built by #set_iiif_cameras) so a
        # client can activate that view when the comment is selected.
        if has_point?(annotation, 'cameraPosition')
          anno_iiif[:scope] = [{ id: camera_uri(index), type: "Annotation" }]
        end

        anno_iiif
      end
    else
      self.iiif_annotations = nil
    end
  end

  def set_iiif_cameras
    if aleph_scene_annotations.present?
      cameras = aleph_scene_annotations.each_with_index.filter_map do |annotation, index|
        next unless has_point?(annotation, 'cameraPosition')

        camera_body = { type: "PerspectiveCamera" }
        camera_body[:lookAt] = point_selector(annotation['cameraTarget']) if has_point?(annotation, 'cameraTarget')

        {
          id: camera_uri(index),
          type: "Annotation",
          motivation: ["painting"],
          # Per-comment cameras are only meant to be activated via a comment's scope,
          # not selected directly or treated as the scene's default camera.
          behavior: ["hidden"],
          body: camera_body,
          target: {
            type: "SpecificResource",
            source: { id: nil, type: "Scene" }, # This will be rewritten with the correct scene URI
            selector: [point_selector(annotation['cameraPosition'])]
          }
        }
      end

      self.iiif_cameras = cameras.presence
    else
      self.iiif_cameras = nil
    end
  end

  # Aleph's raw annotations array, or nil if aleph_scene doesn't have a usable one
  def aleph_scene_annotations
    return nil unless aleph_scene.is_a?(Hash)

    annotations = aleph_scene['annotations']
    return nil unless annotations.is_a?(Array) && annotations.present? && annotations.all? { |a| a.is_a?(Hash) }

    annotations
  end

  def comment_target(annotation)
    target = {
      type: "SpecificResource",
      source: { id: nil, type: "Scene" } # This will be rewritten with the correct scene URI
    }
    target[:selector] = [point_selector(annotation['position'])] if has_point?(annotation, 'position')
    target
  end

  def has_point?(annotation, key)
    point = annotation[key]
    point.present? &&
      point.is_a?(Hash) &&
      ['x', 'y', 'z'].all? { |v| point[v].present? } &&
      ['x', 'y', 'z'].all? { |v| is_numeric? point[v] }
  end

  def point_selector(point)
    {
      type: "PointSelector",
      x: Float(point['x']),
      y: Float(point['y']),
      z: Float(point['z'])
    }
  end

  def anno_uri(index)
    "http://#{Hyrax.config.host_name}/iiif/annotations/commenting/#{media_id}/#{index}"
  end

  def camera_uri(index)
    "#{anno_uri(index)}/camera"
  end

  def set_iiif_transforms
    if (
      aleph_scene &&
      aleph_scene.is_a?(Hash) &&
      ( rotation = aleph_scene.dig('scene', 'rotation') ).present? &&
      rotation.is_a?(Array) &&
      rotation.count == 3 &&
      rotation.all? { |v| is_numeric? v } &&
      rotation.any? { |v| v != 0 }
    )
      self.iiif_transforms = [
        {
          type: "RotateTransform",
          x: Float(rotation[0]) * (180.0 / Math::PI),
          y: Float(rotation[1]) * (180.0 / Math::PI),
          z: Float(rotation[2]) * (180.0 / Math::PI)
        }
      ]
    else
      self.iiif_transforms = nil
    end
  end

  def is_numeric?(value)
    true if Float(value) rescue false
  end
end