module Morphosource
  module Configurable
    extend ActiveSupport::Concern

    included do

      # Geonames user account
      mattr_accessor :geonames_user do
        ENV["GEONAMES_USER"] || "NOT_SET"
      end

      mattr_accessor :ms_init_usr do
        ENV["MS_INIT_USR"] || "NOT_SET"
      end

      mattr_accessor :ms_init_pw do
        ENV["MS_INIT_PW"] || "NOT_SET"
      end

      mattr_accessor :ms_test_pw do
        ENV["MS_TEST_PW"] || "NOT_SET"
      end

      mattr_accessor :ms_test_usr do
        ENV["MS_TEST_USR"] || "NOT_SET"
      end

      # Allowed formats for uploads based on selected Media type
      mattr_accessor :all_formats do
        [".avi", ".bin", ".bmp", ".dcm", ".dicom", ".gif", ".glb", ".gltf", ".bin", ".jp2", ".jpeg", ".jpg", ".m4v", ".mov", ".mp4", ".mpg", ".mpeg", ".mtl", ".obj", ".pdf", ".ply", ".png", ".stl", ".svg", ".tif", ".tiff", ".wmv", ".wrl", ".x3d", ".zip", ".tar"]
      end

      mattr_accessor :image_formats do
        [".bmp", ".dcm", ".dicom", ".gif", ".jp2", ".jpeg", ".jpg", ".png", ".svg", ".tif", ".tiff"]
      end

      mattr_accessor :video_formats do
        [".avi", ".m4v", ".mov", ".mp4", ".mpg", ".mpeg", ".wmv"]
      end

      mattr_accessor :ct_formats do
        [".zip", ".tar"]
      end

      mattr_accessor :photogrammetry_formats do
        [".zip", ".tar", ".jp2", ".tif", ".dng", ".nef", ".crw", ".cr2", ".cr3", ".iiq", ".arw", ".raw", ".rw2"]
      end

      mattr_accessor :mesh_formats do
        [".glb", ".gltf", ".obj", ".ply", ".stl",  ".wrl", ".x3d", ".zip", ".tar"]
      end

      # Allowed formats for attachments (default for documents)
      mattr_accessor :attachment_formats do
        [".txt", ".pdf", ".doc", ".docx"]
      end

      # Allowed formats for Photographic reference attachments
      mattr_accessor :reference_attachment_formats do
        [".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff", ".pdf"]
      end

      mattr_accessor :sequential_section_formats do
        [".zip", ".tar"]
      end

      # right now same as all formats
      mattr_accessor :other_formats do
        self.all_formats
      end

      mattr_accessor :manifest_formats do
        [".xlsx"]
      end

      MEDIA_FORMATS = {
        'Image' => {extensions: image_formats, label_key: 'morphosource.media.format_labels.image'},
        'Video' => {extensions: video_formats, label_key: 'morphosource.media.format_labels.video'},
        'CTImageSeries' => {extensions: ct_formats, label_key: 'morphosource.media.format_labels.ct_mri'},
        'PhotogrammetryImageSeries' => {extensions: photogrammetry_formats, label_key: 'morphosource.media.format_labels.photogrammetry'},
        'Mesh' => {extensions: mesh_formats, label_key: 'morphosource.media.format_labels.mesh'},
        'Other' => {extensions: other_formats, label_key: 'morphosource.media.format_labels.other'},
        'SequentialSectionImageSeries' => {extensions: sequential_section_formats, label_key: 'morphosource.media.format_labels.sequential_section'}
      }

    end
  end
end
