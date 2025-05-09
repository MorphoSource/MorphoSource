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
class Scene < ApplicationRecord
  # Validations
  validates :media_id, presence: true, uniqueness: true
  validates :aleph_scene, presence: true
  validate :is_aleph_scene_hash_or_array?

  # Callbacks
  before_save :ensure_media_id_uniqueness, :set_iiif_annotations, :set_iiif_transforms
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
    if (
      aleph_scene &&
      aleph_scene.is_a?(Hash) &&
      ( annotations = aleph_scene['annotations']).present? &&
      annotations.is_a?(Array) &&
      annotations.length > 0 &&
      annotations.all? { |a| a.is_a?(Hash) }
    )
      self.iiif_annotations = annotations.map.with_index do |annotation, index|
        anno_iiif = {
          id: anno_uri(index),
          type: "Annotation",
          motivation: ["commenting"],
          bodyValue: annotation['label'] || "No Label"
        }
        if annotation['description'].present? && annotation['description'].is_a?(String)
          anno_iiif[:summary] = { "none": [ annotation['description'] ] } 
        end

        # scene target with positioning if present

        target = {
          type: "SpecificResource",
          source: [{
            id: nil, # This will be rewritten with correct scene URI
            type: "Scene"
          }]
        }

        if (
          annotation['position'].present? && 
          annotation['position'].is_a?(Hash) &&
          ['x', 'y', 'z'].all? { |v| annotation.dig('position', v).present? } &&
          ['x', 'y', 'z'].all? { |v| is_numeric? annotation.dig('position', v) }
        )
          target[:selector] = [{
            type: "PointSelector",
            x: Float(annotation['position']['x']),
            y: Float(annotation['position']['y']),
            z: Float(annotation['position']['z'])
          }]
        end

        anno_iiif[:target] = target

        # scope content state with camera annotation if viewpoint present

        if (
          annotation['cameraPosition'].present? &&
          annotation['cameraPosition'].is_a?(Hash) &&
          ['x', 'y', 'z'].all? { |v| annotation.dig('cameraPosition', v).present? } &&
          ['x', 'y', 'z'].all? { |v| is_numeric? annotation.dig('cameraPosition', v) }
        )
          scope = {
            "@context": "http://iiif.io/api/presentation/4/context.json",
            id: "#{anno_uri(index)}/scope",
            type: "Annotation",
            motivation: ["contentState"],
            target: {
              id: nil, # This will be rewritten with correct scene URI
              type: "Scene",
              items: [{
                id: "#{anno_uri(index)}/scope/camera",
                type: "Annotation",
                motivation: ["painting"],
                body: {
                  id: "#{anno_uri(index)}/scope/camera/1",
                  type: "PerspectiveCamera", 
                },
                target: {
                  type: "SpecificResource",
                  source: [{
                    id: nil, # This will be rewritten with correct scene URI
                    type: "Scene"
                  }],
                  selector: [{
                    type: "PointSelector",
                    x: Float(annotation['cameraPosition']['x']),
                    y: Float(annotation['cameraPosition']['y']),
                    z: Float(annotation['cameraPosition']['z'])
                  }]
                }
              }]
            }
          }

          if (
            annotation['cameraTarget'].present? &&
            annotation['cameraTarget'].is_a?(Hash) &&
            ['x', 'y', 'z'].all? { |v| annotation.dig('cameraTarget', v).present? } &&
            ['x', 'y', 'z'].all? { |v| is_numeric? annotation.dig('cameraTarget', v) }
          )
            scope[:target][:items][0][:body][:lookAt] = {
              type: "PointSelector",
              x: Float(annotation['cameraTarget']['x']),
              y: Float(annotation['cameraTarget']['y']),
              z: Float(annotation['cameraTarget']['z'])
            }
          end

          anno_iiif[:target][:scope] = scope
        end

        anno_iiif
      end
    else
      self.iiif_annotations = nil
    end
  end

  def anno_uri(index)
    "http://#{Hyrax.config.host_name}/iiif/annotations/commenting/#{media_id}/#{index}"
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