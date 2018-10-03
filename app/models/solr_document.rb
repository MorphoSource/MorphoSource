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

  # Add custom metadata fields to show view

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
  def physical_object_type
    self[Solrizer.solr_name('physical_object_type', :stored_searchable)]
  end

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

  def institution
    self[Solrizer.solr_name('institution', :stored_searchable)]
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

  # Image Capture Event
  def software
    self[Solrizer.solr_name('software', :stored_searchable)]
  end

  def ice_modality
      self[Solrizer.solr_name('ice_modality', :stored_searchable)]   
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
  
  def filter_material
      self[Solrizer.solr_name('filter_material', :stored_searchable)]   
  end 
    
  def filter_thickness
      self[Solrizer.solr_name('filter_thickness', :stored_searchable)]   
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
