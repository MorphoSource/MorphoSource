# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # Adds MorphoSource behaviors to the SolrDocument
  include ::Morphosource::SolrDocumentBehavior

  # work type specific methods
  include ::Morphosource::Solr::BiologicalSpecimen
  include ::Morphosource::Solr::Collection
  include ::Morphosource::Solr::CulturalHeritageObject
  include ::Morphosource::Solr::Device
  include ::Morphosource::Solr::FileSet
  include ::Morphosource::Solr::ImagingEvent
  include ::Morphosource::Solr::Location
  include ::Morphosource::Solr::Media
  include ::Morphosource::Solr::MediaList
  include ::Morphosource::Solr::Organization
  include ::Morphosource::Solr::OrganizationCollection
  include ::Morphosource::Solr::Permissions
  include ::Morphosource::Solr::PhysicalObject
  include ::Morphosource::Solr::ProcessingEvent
  include ::Morphosource::Solr::SequentialSectionList
  include ::Morphosource::Solr::Taxonomy

  # Query SolrDocument instances with multiple query statements
  # Maximum number of instances/rows is 1000 by default
  #
  # @param query [Hash, String] Query statement(s), can be a single string or multiple hash queries (combined with AND)
  # @param opts  [Hash] Optional Solr configuration parameters, such as :rows or :page
  #
  # @return [Array<SolrDocument>] Array of queried SolrDocument instances
  def self.where(query = {}, opts: {})
    if query.instance_of?(String)
      q = query
    else
      # can't search solr for blank values, need to use "-field:*"" for that
      exclude_values = ["", [], {}, nil] # all .present? falsy values except false itself
      query = query.reject { |k, v| exclude_values.include?(v) }
      return [] if !query.present?
      q = query.map { |k, v| "#{k}:#{v}" }.join(" AND ")
    end

    default_params = { rows: 1000 }
    params = default_params.merge(q: q).merge(opts)
    repository.search(params).documents
  end

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

  # MorphoSource semantic field mapping
  use_extension(Blacklight::Document::Morphosource)

  # Fedora object properties corresponding to solr values
  PROPERTIES = [BIOLOGICAL_SPECIMEN_PROPERTIES,
                CULTURAL_HERITAGE_OBJECT_PROPERTIES,
                FILE_SET_PROPERTIES,
                IMAGING_EVENT_PROPERTIES,
                LOCATION_PROPERTIES, # shared by specimens, chos, and organizations
                MEDIA_PROPERTIES,
                ORGANIZATION_PROPERTIES,
                PERMISSIONS_PROPERTIES, # shared by organizations and media
                PHYSICAL_OBJECT_PROPERTIES, # shared by specimens and chos
                PROCESSING_EVENT_PROPERTIES,
                TAXONOMY_PROPERTIES].flatten

  PROPERTIES.each do |property|
    define_method(property) do
      self[ActiveFedora.index_field_mapper.solr_name(property, :stored_searchable)]
    end
  end

  # API fields
  def has_model
    self[ActiveFedora.index_field_mapper.solr_name('has_model', :symbol)]
  end

  def title
    self['title_tesim']
  end

  def download_reviewers
    self['download_reviewers_ssim'] || []
  end

  def creator
    self['creator_tesim']
  end

  # Add custom metadata fields to show view
  def in_works_ids
    self[ActiveFedora.index_field_mapper.solr_name('in_works_ids', :stored_searchable)]
  end

  def sortable_title
    self[ActiveFedora.index_field_mapper.solr_name('title', :stored_sortable)]
  end

  # Derivative download field
  def access_control_id
    self[ActiveFedora.index_field_mapper.solr_name('accessControl', :symbol)]
  end

  # Processing Event & Image Capture Event
  def software
    self[ActiveFedora.index_field_mapper.solr_name('software', :stored_searchable)]
  end

  # Download fields
  def download_groups
    self["download_access_group_ssim"]
  end

  def download_people
    self["download_access_person_ssim"]
  end

  def download_access_groups
    self["download_access_group_ssim"]
  end

  def download_access_person
    self["download_access_person_ssim"]
  end

  def read_access_group
    self["read_access_group_ssim"]
  end

  def read_access_person
    self["read_access_person_ssim"]
  end

  def edit_access_group
    self["edit_access_group_ssim"]
  end

  def edit_access_person
    self["edit_access_person_ssim"]
  end

  def open?
    self["visibility_ssi"] == 'open'
  end

  def user_with_ownership
    self["owner_ssim"].presence || self["depositor_ssim"]
  end

  # Tags
  def specimen?
    self["has_model_ssim"] == ["BiologicalSpecimen"]
  end

  # Remote manifests
  def remote_manifest_url
    self['remote_manifest_url_ssi']
  end

  def has_remote_manifest?
    self['remote_manifest_url_ssi'].present?
  end
end
