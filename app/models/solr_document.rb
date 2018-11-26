# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior


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

  # MorphoSource customizations

  # Fileset methods
  def file_ext
    File.extname(label)
  end

  def mesh? # TODO: Needs to be adjusted to use mime types when FITS issue is dealt with
    accepted_formats = [".ply", ".stl", ".obj", ".gltf"]
    accepted_formats.include? file_ext
  end

  def mesh_mime_type # TODO: Temporary, should not exist forever
    mesh_mime_types = { ".ply" => "application/ply",
                        ".stl" => "application/sla",
                        ".obj" => "text/plain",
                        ".gltf" => "model/gltf+json" }
    mesh_mime_types[file_ext]
  end

  # Add custom metadata fields to show view
  def in_works_ids
    self[Solrizer.solr_name('in_works_ids', :stored_searchable)]
  end

  def sortable_title
    self[Solrizer.solr_name('title', :stored_sortable)]
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

  def map_type
    self[Solrizer.solr_name('map_type', :stored_searchable)]
  end

  def media_type
    self[Solrizer.solr_name('media_type', :stored_searchable)]
  end

  def modality
    self[Solrizer.solr_name('modality', :stored_searchable)]
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

  def current_location
    self[Solrizer.solr_name('current_location', :stored_searchable)]
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


  def short_title
    self[Solrizer.solr_name('short_title', :stored_searchable)]
  end

  # Institution fields
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

  # Device fields, also uses modality currently in media above
  def facility
    self[Solrizer.solr_name('facility', :stored_searchable)]
  end

  # Processing Event
  def software
    self[Solrizer.solr_name('software', :stored_searchable)]
  end


  # Image Capture Event
  def ie_modality
      self[Solrizer.solr_name('ie_modality', :stored_searchable)]
  end

  def software
      self[Solrizer.solr_name('software', :stored_searchable)]
  end

  def exposure_time
      self[Solrizer.solr_name('exposure_time', :stored_searchable)]
  end

  def flux_normalization
      self[Solrizer.solr_name('flux_normalization', :stored_searchable)]
  end

  def geometric_calibration
      self[Solrizer.solr_name('geometric_calibration', :stored_searchable)]
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
end
