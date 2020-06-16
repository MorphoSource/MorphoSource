# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # Adds MorphoSource behaviors to the SolrDocument
  include Morphosource::SolrDocumentBehavior

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension( Hydra::ContentNegotiation )

  # Add custom metadata fields to show view
  def in_works_ids
    self[Solrizer.solr_name('in_works_ids', :stored_searchable)]
  end

  def sortable_title
    self[Solrizer.solr_name('title', :stored_sortable)]
  end

  # Add custom column to dashboard works list
  def file_set_visibilities
    self["file_set_visibilities_ssim"]
  end

  # Media Fields
  def agreement_uri
    self[Solrizer.solr_name('agreement_uri', :stored_searchable)]
  end

  def cite_as
    self[Solrizer.solr_name('cite_as', :stored_searchable)]
  end

  def funding
    self[Solrizer.solr_name('funding', :stored_searchable)]
  end

  def fileset_visibility
    self[Solrizer.solr_name('fileset_visibility', :stored_searchable)]
  end

  def fileset_accessibility
    self[Solrizer.solr_name('fileset_accessibility', :stored_searchable)]
  end

  def map_type
    self[Solrizer.solr_name('map_type', :stored_searchable)]
  end

  def media_type
    self[Solrizer.solr_name('media_type', :stored_searchable)]
  end

  def orientation
    self[Solrizer.solr_name('orientation', :stored_searchable)]
  end

  def part
    self[Solrizer.solr_name('part', :stored_searchable)]
  end

  def rights_holder
    self[Solrizer.solr_name('rights_holder', :stored_searchable)]
  end

  def scale_bar
    self[Solrizer.solr_name('scale_bar', :stored_searchable)]
  end

  def series_type
    self[Solrizer.solr_name('series_type', :stored_searchable)]
  end

  def short_description
    self[Solrizer.solr_name('short_description', :stored_searchable)]
  end

  def side
    self[Solrizer.solr_name('side', :stored_searchable)]
  end

  def unit
    self[Solrizer.solr_name('unit', :stored_searchable)]
  end

  def x_spacing
    self[Solrizer.solr_name('x_spacing', :stored_searchable)]
  end

  def y_spacing
    self[Solrizer.solr_name('y_spacing', :stored_searchable)]
  end

  def z_spacing
    self[Solrizer.solr_name('z_spacing', :stored_searchable)]
  end

  # Physical Object Fields
  def bibliographic_citation
    self[Solrizer.solr_name('bibliographic_citation', :stored_searchable)]
  end

  def catalog_number
    self[Solrizer.solr_name('catalog_number', :stored_searchable)]
  end

  def collection_code
    self[Solrizer.solr_name('collection_code', :stored_searchable)]
  end

  def institution_code
    self[Solrizer.solr_name('institution_code', :stored_searchable)]
  end

  def current_location
    self[Solrizer.solr_name('current_location', :stored_searchable)]
  end

  def processing_activity
    self[Solrizer.solr_name('processing_activity', :stored_searchable)]
  end

  def processing_activity_type
    self[Solrizer.solr_name('processing_activity_type', :stored_searchable)]
  end

  def processing_activity_software
    self[Solrizer.solr_name('processing_activity_software', :stored_searchable)]
  end

  def processing_activity_description
    self[Solrizer.solr_name('processing_activity_description', :stored_searchable)]
  end

  def geographic_coordinates
    if (latitude && longitude)
      "Latitude: " + latitude[0] + ", Longitude: " + longitude[0]
    elsif latitude
      "Latitude: " + latitude[0]
    elsif longitude
      "Longitude: " + longitude[0]
    end
  end

  def latitude
    self[Solrizer.solr_name('latitude', :stored_searchable)]
  end

  def longitude
    self[Solrizer.solr_name('longitude', :stored_searchable)]
  end

  def numeric_time
    self[Solrizer.solr_name('numeric_time', :stored_searchable)]
  end

  def original_location
    self[Solrizer.solr_name('original_location', :stored_searchable)]
  end

  def periodic_time
    self[Solrizer.solr_name('periodic_time', :stored_searchable)]
  end

  def physical_object_type
    self[Solrizer.solr_name('physical_object_type', :stored_searchable)]
  end

  def vouchered
    self[Solrizer.solr_name('vouchered', :stored_searchable)]
  end

  def member_ids
    self[Solrizer.solr_name('member_ids', :symbol)]
  end

  # Biological Specimens only
  def idigbio_recordset_id
    self[Solrizer.solr_name('idigbio_recordset_id', :stored_searchable)]
  end

  def idigbio_uuid
    self[Solrizer.solr_name('idigbio_uuid', :stored_searchable)]
  end

  def is_type_specimen
    self[Solrizer.solr_name('is_type_specimen', :stored_searchable)]
  end

  def occurrence_id
    self[Solrizer.solr_name('occurrence_id', :stored_searchable)]
  end

  def sex
    self[Solrizer.solr_name('sex', :stored_searchable)]
  end

  def canonical_taxonomy
    self[Solrizer.solr_name('canonical_taxonomy', :stored_searchable)]
  end

  # CHOs only
  def cho_type
    self[Solrizer.solr_name('cho_type', :stored_searchable)]
  end

  def material
    self[Solrizer.solr_name('material', :stored_searchable)]
  end

  # images
  def bits_per_sample
    self[Solrizer.solr_name('bits_per_sample', :stored_searchable)]
  end

  def color_space
    self[Solrizer.solr_name('color_space', :stored_searchable)]
  end

  def compression
    self[Solrizer.solr_name('compression', :stored_searchable)]
  end

  # dicom
  def spacing_between_slices
    self[Solrizer.solr_name('spacing_between_slices', :stored_searchable)]
  end

  def modality
    self[Solrizer.solr_name('modality', :stored_searchable)]
  end

  def secondary_capture_device_manufacturer
    self[Solrizer.solr_name('secondary_capture_device_manufacturer', :stored_searchable)]
  end

  def secondary_capture_device_software_vers
    self[Solrizer.solr_name('secondary_capture_device_software_vers', :stored_searchable)]
  end

  def file_type_extension
    self[Solrizer.solr_name('file_type_extension', :stored_searchable)]
  end

  def image_type
    self[Solrizer.solr_name('image_type', :stored_searchable)]
  end

  def study_date
    self[Solrizer.solr_name('study_date', :stored_searchable)]
  end

  def series_date
    self[Solrizer.solr_name('series_date', :stored_searchable)]
  end

  def content_date
    self[Solrizer.solr_name('content_date', :stored_searchable)]
  end

  def study_time
    self[Solrizer.solr_name('study_time', :stored_searchable)]
  end

  def series_time
    self[Solrizer.solr_name('series_time', :stored_searchable)]
  end

  def content_time
    self[Solrizer.solr_name('content_time', :stored_searchable)]
  end

  def accession_number
    self[Solrizer.solr_name('accession_number', :stored_searchable)]
  end

  def instance_number
    self[Solrizer.solr_name('instance_number', :stored_searchable)]
  end

  def image_position_patient
    self[Solrizer.solr_name('image_position_patient', :stored_searchable)]
  end

  def image_orientation_patient
    self[Solrizer.solr_name('image_orientation_patient', :stored_searchable)]
  end

  def samples_per_pixel
    self[Solrizer.solr_name('samples_per_pixel', :stored_searchable)]
  end

  def photometric_interpretation
    self[Solrizer.solr_name('photometric_interpretation', :stored_searchable)]
  end

  def rows
    self[Solrizer.solr_name('rows', :stored_searchable)]
  end

  def columns
    self[Solrizer.solr_name('columns', :stored_searchable)]
  end

  def pixel_spacing
    self[Solrizer.solr_name('pixel_spacing', :stored_searchable)]
  end

  def slice_thickness
    self[Solrizer.solr_name('slice_thickness', :stored_searchable)]
  end

  def number_of_images_in_set
    self[Solrizer.solr_name('number_of_images_in_set', :stored_searchable)]
  end

  def bits_allocated
    self[Solrizer.solr_name('bits_allocated', :stored_searchable)]
  end

  def bits_stored
    self[Solrizer.solr_name('bits_stored', :stored_searchable)]
  end

  def high_bit
    self[Solrizer.solr_name('high_bit', :stored_searchable)]
  end

  def pixel_representation
    self[Solrizer.solr_name('pixel_representation', :stored_searchable)]
  end

  def window_center
    self[Solrizer.solr_name('window_center', :stored_searchable)]
  end

  def window_width
    self[Solrizer.solr_name('window_width', :stored_searchable)]
  end

  def rescale_intercept
    self[Solrizer.solr_name('rescale_intercept', :stored_searchable)]
  end

  def rescale_slope
    self[Solrizer.solr_name('rescale_slope', :stored_searchable)]
  end

  def window_center_and_width_explanation
    self[Solrizer.solr_name('window_center_and_width_explanation', :stored_searchable)]
  end


  def exposure_time
    self[Solrizer.solr_name('exposure_time', :stored_searchable)]
  end

  def pixel_spacing_calibration_description
    self[Solrizer.solr_name('pixel_spacing_calibration_description', :stored_searchable)]
  end

  def pixel_spacing_calibration_type
    self[Solrizer.solr_name('pixel_spacing_calibration_type', :stored_searchable)]
  end

  def contrast_frame_averaging
    self[Solrizer.solr_name('contrast_frame_averaging', :stored_searchable)]
  end

  def images_in_acquisition
    self[Solrizer.solr_name('images_in_acquisition', :stored_searchable)]
  end

  def KVP
    self[Solrizer.solr_name('KVP', :stored_searchable)]
  end

  def generator_power
    self[Solrizer.solr_name('generator_power', :stored_searchable)]
  end

  def x_ray_tube_current
    self[Solrizer.solr_name('x_ray_tube_current', :stored_searchable)]
  end

  def container_description
    self[Solrizer.solr_name('container_description', :stored_searchable)]
  end

  def generator_id
    self[Solrizer.solr_name('generator_id', :stored_searchable)]
  end

  def detector_description
    self[Solrizer.solr_name('detector_description', :stored_searchable)]
  end

  def distance_source_to_patient
    self[Solrizer.solr_name('distance_source_to_patient', :stored_searchable)]
  end

  def distance_source_to_detector
    self[Solrizer.solr_name('distance_source_to_detector', :stored_searchable)]
  end

  def anode_target_material
    self[Solrizer.solr_name('anode_target_material', :stored_searchable)]
  end

  def spiral_pitch_factor
    self[Solrizer.solr_name('spiral_pitch_factor', :stored_searchable)]
  end

  def number_of_series_related_instances
    self[Solrizer.solr_name('number_of_series_related_instances', :stored_searchable)]
  end


  def short_title
    self[Solrizer.solr_name('short_title', :stored_searchable)]
  end

  # Organization fields
  def organization_type
    self[Solrizer.solr_name('organization_type', :stored_searchable)]
  end

  def institution_code
    self[Solrizer.solr_name('institution_code', :stored_searchable)]
  end

  def address
    self[Solrizer.solr_name('address', :stored_searchable)]
  end

  def city
    self[Solrizer.solr_name('city', :stored_searchable)]
  end

  def state_province
    self[Solrizer.solr_name('state_province', :stored_searchable)]
  end

  def country
    self[Solrizer.solr_name('country', :stored_searchable)]
  end

  def institution_name
    self[Solrizer.solr_name('institution_name', :stored_searchable)]
  end

  def contact_person
    self[Solrizer.solr_name('contact_person', :stored_searchable)]
  end

  # Processing Event & Image Capture Event
  def software
    self[Solrizer.solr_name('software', :stored_searchable)]
  end

  # Image Capture Event
  def ie_modality
      self[Solrizer.solr_name('ie_modality', :stored_searchable)]
  end

  def exposure_time
      self[Solrizer.solr_name('exposure_time', :stored_searchable)]
  end

  def flux_normalization
      self[Solrizer.solr_name('flux_normalization', :stored_searchable)]
  end

  def pixel_spacing_calibration
      self[Solrizer.solr_name('pixel_spacing_calibration', :stored_searchable)]
  end

  def shading_correction
      self[Solrizer.solr_name('shading_correction', :stored_searchable)]
  end

  def filter
      self[Solrizer.solr_name('filter', :stored_searchable)]
  end

  def frame_averaging
      self[Solrizer.solr_name('frame_averaging', :stored_searchable)]
  end

  def projections
      self[Solrizer.solr_name('projections', :stored_searchable)]
  end

  def voltage
      self[Solrizer.solr_name('voltage', :stored_searchable)]
  end

  def power
      self[Solrizer.solr_name('power', :stored_searchable)]
  end

  def amperage
      self[Solrizer.solr_name('amperage', :stored_searchable)]
  end

  def surrounding_material
      self[Solrizer.solr_name('surrounding_material', :stored_searchable)]
  end

  def xray_tube_type
      self[Solrizer.solr_name('xray_tube_type', :stored_searchable)]
  end

  def target_type
      self[Solrizer.solr_name('target_type', :stored_searchable)]
  end

  def detector_type
      self[Solrizer.solr_name('detector_type', :stored_searchable)]
  end

  def detector_pixels_x
    self[Solrizer.solr_name('detector_pixels_x', :stored_searchable)]
  end

  def detector_pixel_size_x
    self[Solrizer.solr_name('detector_pixel_size_x', :stored_searchable)]
  end

  def detector_pixels_y
    self[Solrizer.solr_name('detector_pixels_y', :stored_searchable)]
  end

  def detector_pixel_size_y
    self[Solrizer.solr_name('detector_pixel_size_y', :stored_searchable)]
  end

  def detector_configuration
      self[Solrizer.solr_name('detector_configuration', :stored_searchable)]
  end

  def source_object_distance
      self[Solrizer.solr_name('source_object_distance', :stored_searchable)]
  end

  def source_detector_distance
      self[Solrizer.solr_name('source_detector_distance', :stored_searchable)]
  end

  def target_material
      self[Solrizer.solr_name('target_material', :stored_searchable)]
  end

  def rotation_number
      self[Solrizer.solr_name('rotation_number', :stored_searchable)]
  end

  def phase_contrast
      self[Solrizer.solr_name('phase_contrast', :stored_searchable)]
  end

  def optical_magnification
      self[Solrizer.solr_name('optical_magnification', :stored_searchable)]
  end

  def acquisition_type
      self[Solrizer.solr_name('acquisition_type', :stored_searchable)]
  end

  def focal_length_type
      self[Solrizer.solr_name('focal_length_type', :stored_searchable)]
  end

  def background_removal
      self[Solrizer.solr_name('background_removal', :stored_searchable)]
  end

  def lens_make
      self[Solrizer.solr_name('lens_make', :stored_searchable)]
  end

  def lens_model
      self[Solrizer.solr_name('lens_model', :stored_searchable)]
  end

  def light_source
      self[Solrizer.solr_name('light_source', :stored_searchable)]
  end

  def focal_length
      self[Solrizer.solr_name('focal_length', :stored_searchable)]
  end

  def aperture_value
      self[Solrizer.solr_name('aperture_value', :stored_searchable)]
  end

  def iso_speed_ratings
      self[Solrizer.solr_name('iso_speed_ratings', :stored_searchable)]
  end

  def shutter_speed
      self[Solrizer.solr_name('shutter_speed', :stored_searchable)]
  end

  # mesh
  def point_count
    self[Solrizer.solr_name('point_count', :stored_searchable)]
  end

  def face_count
    self[Solrizer.solr_name('face_count', :stored_searchable)]
  end

  def edges_per_face
    self[Solrizer.solr_name('edges_per_face', :stored_searchable)]
  end

  def color_format
    self[Solrizer.solr_name('color_format', :stored_searchable)]
  end

  def normals_format
    self[Solrizer.solr_name('normals_format', :stored_searchable)]
  end

  def has_uv_space
    self[Solrizer.solr_name('has_uv_space', :stored_searchable)]
  end

  def vertex_color
    self[Solrizer.solr_name('vertex_color', :stored_searchable)]
  end

  def bounding_box_x
    self[Solrizer.solr_name('bounding_box_x', :stored_searchable)]
  end

  def bounding_box_y
    self[Solrizer.solr_name('bounding_box_y', :stored_searchable)]
  end

  def bounding_box_z
    self[Solrizer.solr_name('bounding_box_z', :stored_searchable)]
  end

  def centroid_x
    self[Solrizer.solr_name('centroid_x', :stored_searchable)]
  end

  def centroid_y
    self[Solrizer.solr_name('centroid_y', :stored_searchable)]
  end

  def centroid_z
    self[Solrizer.solr_name('centroid_z', :stored_searchable)]
  end

  # Zip archive contents file characterization fields

  def contents_mime_type
    self[Solrizer.solr_name('contents_mime_type', :stored_searchable)]
  end

  def contents_file_name
    self[Solrizer.solr_name('contents_file_name', :stored_searchable)]
  end

  def contents_file_size
    self[Solrizer.solr_name('contents_file_size', :stored_searchable)]
  end

  def contents_accepted_file_count
    self[Solrizer.solr_name('contents_accepted_file_count', :stored_searchable)]
  end

  # Taxonomy fields

  def taxonomy_domain
    self[Solrizer.solr_name('taxonomy_domain', :stored_searchable)]
  end

  def taxonomy_kingdom
    self[Solrizer.solr_name('taxonomy_kingdom', :stored_searchable)]
  end

  def taxonomy_phylum
    self[Solrizer.solr_name('taxonomy_phylum', :stored_searchable)]
  end

  def taxonomy_superclass
    self[Solrizer.solr_name('taxonomy_superclass', :stored_searchable)]
  end

  def taxonomy_class
    self[Solrizer.solr_name('taxonomy_class', :stored_searchable)]
  end

  def taxonomy_subclass
    self[Solrizer.solr_name('taxonomy_subclass', :stored_searchable)]
  end

  def taxonomy_superorder
    self[Solrizer.solr_name('taxonomy_superorder', :stored_searchable)]
  end

  def taxonomy_order
    self[Solrizer.solr_name('taxonomy_order', :stored_searchable)]
  end

  def taxonomy_suborder
    self[Solrizer.solr_name('taxonomy_suborder', :stored_searchable)]
  end

  def taxonomy_superfamily
    self[Solrizer.solr_name('taxonomy_superfamily', :stored_searchable)]
  end

  def taxonomy_family
    self[Solrizer.solr_name('taxonomy_family', :stored_searchable)]
  end

  def taxonomy_subfamily
    self[Solrizer.solr_name('taxonomy_subfamily', :stored_searchable)]
  end

  def taxonomy_tribe
    self[Solrizer.solr_name('taxonomy_tribe', :stored_searchable)]
  end

  def taxonomy_genus
    self[Solrizer.solr_name('taxonomy_genus', :stored_searchable)]
  end

  def taxonomy_subgenus
    self[Solrizer.solr_name('taxonomy_subgenus', :stored_searchable)]
  end

  def taxonomy_species
    self[Solrizer.solr_name('taxonomy_species', :stored_searchable)]
  end

  def taxonomy_subspecies
    self[Solrizer.solr_name('taxonomy_subspecies', :stored_searchable)]
  end

  def trusted
    self[Solrizer.solr_name('trusted', :stored_searchable)]
  end

  # Download fields
  def download_groups
    self["download_access_group_ssim"]
  end

  def download_people
    self["download_access_person_ssim"]
  end

end
