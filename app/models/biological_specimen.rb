class BiologicalSpecimen < Morphosource::Works::Base

  include ::Hyrax::WorkBehavior
  include Morphosource::PhysicalObjectBehavior
  include Morphosource::PersistentIdentifiersBehavior
  validates_with Morphosource::ParentChildValidator
  before_create :controlled_value_filter, :date_filter, :set_idigbio_link_origin_when_create
  before_update do
    controlled_value_filter
    date_filter
  end
  before_save :capture_original_organization_id, if: :organization_id_changed?
  after_update :reindex_media, :update_ark_status
  after_create :mint_ark
  before_destroy :prevent_destroy_with_media, prepend: true
  after_destroy :delete_ark_if_reserved

  self.indexer = BiologicalSpecimenIndexer

  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = []

  validates :title, presence: { message: I18n.t('morphosource.validation.missing.title') }

  include Morphosource::PhysicalObjectMetadata
  include Morphosource::LocationMetadata
  include ::Morphosource::BasicMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Morphosource::BiologicalSpecimenMetadata

  # Valkyrie foreign key associations, if Valkyrie::ID is found will convert to string
  self.valkyrie_association_attributes = [:taxonomy_id]

  # :occurrence_id_changed? may change to :will_save_change_to_occurrence_id?
  # if ActiveFedora updates to reflect the Rails 5.1+ ActiveRecord/ActiveModel API
  after_update :update_from_idigbio, if: :occurrence_id_changed?
  after_update :check_for_media_organization_transfer, if: :organization_id_changed?

  def update_from_idigbio
    if occurrence_id.present?
      if (params_for_update = Morphosource::IDigBioGetMetadataService.call(self.to_solr)).present?
        if Morphosource::IDigBioGetMetadataService.idigbio_record_different_from_specimen?(self.to_solr, params_for_update)
          Morphosource::IDigBioUpdateService.call(id, save_work=true, system_update=false, params_for_update)
        end
      end
    end
  end

  def set_idigbio_link_origin_when_create
    if self.idigbio_uuid.present?
      self.idigbio_link_origin = ["user"]
    end
  end

  def best_taxonomy
    if canonical_taxonomy.present?
      canonical_taxonomy_object
    else
      taxonomies&.first
    end
  end

  def taxonomies
    Hyrax.query_service.find_many_by_ids(ids: taxonomy_id.to_a)
  end

  def taxonomies_titles
    taxonomies.map{ |t| t.title.first }
  end

  def canonical_taxonomy_object
    return nil unless canonical_taxonomy.present?
    Hyrax.query_service.find_by(id: canonical_taxonomy.first)
  end

  def canonical_taxonomy_title
    return nil unless canonical_taxonomy.first.present?
    canonical_taxonomy_object.title.first
  end

  # all taxonomies except the canonical taxonomy
  def other_taxonomies
    taxonomies.reject{|taxonomy| taxonomy.id == canonical_taxonomy.first}
  end

  # does not include the canonical taxonomy
  def trusted_taxonomies
    other_taxonomies.select{|taxonomy| taxonomy.trusted == ["Yes"]}
  end

  def gbif_taxonomies
    other_taxonomies.select{|taxonomy| taxonomy.gbif_key.present? }
  end

  # returns an array of present gbif taxonomy terms [kingdom, phylum, class, etc.]
  # returns all terms for all gbif taxonomies with no specific ordering (for solr indexing)
  def gbif_taxonomy_terms
    gbif_taxonomies.map { |t| t.gbif_taxonomy_array }.flatten
  end

  # does not include the canonical taxonomy
  # any taxonomy that is not trusted or gbif
  def user_taxonomies
    other_taxonomies.reject{|taxonomy| taxonomy.trusted == ["Yes"] || taxonomy.gbif_key.present? }
  end

  def record_source
    if idigbio_uuid.present?
      'iDigBio Aggregator'
    else
      'User Created'
    end
  end


  private
    def add_id_to_title # this is non-functional!!
      unless self.title && self.id && self.title.first.to_s.start_with?("S#{self.id.to_s}: ")
        self.title.set("S#{self.id.to_s}: #{self.title.first.to_s}")
      end
    end

    def reindex_media
      # reindex media is needed when certain PO fields have been changed
      if self.title_changed? || self.occurrence_id_changed?
        self.media.each do |media|
          UpdateWorkIndexJob.perform_later(media.id)
        end
      end
    end

    def date_attributes_for_filter
      [ :date_created ]
    end

    def controlled_attributes
      { :sex => Morphosource::SexFieldService.new }
    end

end
