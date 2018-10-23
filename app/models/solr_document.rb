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

  def institution
    self[Solrizer.solr_name('institution', :stored_searchable)]
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
end
