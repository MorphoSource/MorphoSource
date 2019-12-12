module Morphosource
  module Configurable
    extend ActiveSupport::Concern

    included do

      # Geonames user account
      mattr_accessor :geonames_user do
        ENV["GEONAMES_USER"] || "NOT_SET"
      end

      # Allowed formats for uploads based on selected Media type
      mattr_accessor :all_formats do
        [".avi", ".bin", ".bmp", ".dcm", ".dicom", ".gif", ".glb", ".gltf", ".bin", ".jp2", ".jpeg", ".jpg", ".m4v", ".mov", ".mp4", ".mpg", ".mpeg", ".mtl", ".obj", ".pdf", ".ply", ".png", ".stl", ".tif", ".tiff", ".wmv", ".wrl", ".x3d", ".zip"]
      end

      mattr_accessor :image_formats do
        [".bmp", ".dcm", ".dicom", ".gif", ".jp2", ".jpeg", ".jpg", ".png", ".tif", ".tiff"]
      end

      mattr_accessor :video_formats do
        [".avi", ".m4v", ".mov", ".mp4", ".mpg", ".mpeg", ".wmv"]
      end

      mattr_accessor :ct_formats do
        [".zip"]
      end

      mattr_accessor :photogrammetry_formats do
        [".zip"]
      end

      mattr_accessor :mesh_formats do
        [".bin", ".bmp", ".dcm", ".dicom", ".gif", ".glb", ".gltf", ".jp2", ".jpeg", ".jpg", ".mtl", ".obj", ".obj", ".ply", ".png", ".stl", ".tif", ".tiff", ".wrl", ".x3d", ".zip"]
      end

      # right now same as all formats
      mattr_accessor :other_formats do
        self.all_formats
      end

      MEDIA_FORMATS = {
        'Image' => {extensions: image_formats, label: I18n.t('morphosource.media.format_labels.image')},
        'Video' => {extensions: video_formats, label: I18n.t('morphosource.media.format_labels.video')},
        'CTImageSeries' => {extensions: ct_formats, label: I18n.t('morphosource.media.format_labels.ct_mri')},
        'PhotogrammetryImageSeries' => {extensions: photogrammetry_formats, label: I18n.t('morphosource.media.format_labels.photogrammetry')},
        'Mesh' => {extensions: mesh_formats, label: I18n.t('morphosource.media.format_labels.mesh')},
        'Other' => {extensions: other_formats, label: I18n.t('morphosource.media.format_labels.other')}
      }

    end
  end
end
