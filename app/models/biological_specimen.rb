class BiologicalSpecimen < Morphosource::Works::Base

  include ::Hyrax::WorkBehavior
  include Morphosource::PhysicalObjectBehavior
  include Morphosource::BiologicalSpecimeniDigBioUpdateBehavior
  validates_with Morphosource::ParentChildValidator
  before_create :controlled_value_filter, :date_filter, :set_idigbio_link_origin_when_create
  before_update do
    controlled_value_filter
    date_filter
  end
  after_update :reindex_media

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

  def set_idigbio_link_origin_when_create
    if self.idigbio_uuid.present?
      self.idigbio_link_origin = ["user"]
    end
  end

  # :occurrence_id_changed? may change to :will_save_change_to_occurrence_id?
  # if ActiveFedora updates to reflect the Rails 5.1+ ActiveRecord/ActiveModel API
  before_update :update_metadata_from_idigbio_occurrence_id, if: :occurrence_id_changed?

  def best_taxonomy
    if canonical_taxonomy.present?
      canonical_taxonomy_object
    else
      taxonomies&.first
    end
  end

  def taxonomies
    Taxonomy.find(taxonomy_id.to_a)
  end

  def taxonomies_titles
    taxonomies.map{ |t| t.title.first }
  end

  def canonical_taxonomy_object
    return nil unless canonical_taxonomy.present?
    Taxonomy.find(canonical_taxonomy.first)
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

  def occurrence_id_valid?
    # valid if 8 characters minimum AND has both a letter and a number
    occurrence_id.present? && occurrence_id.first.length >= 8 &&
      occurrence_id.first.count("0-9") > 0 && occurrence_id.first.count("a-zA-Z") > 0
  end

  def idigbio_occurrence_id_results
    @idigbio_occurrence_id_results ||= Morphosource::IDigBio.search({'occurrenceid' => self.occurrence_id.first})
  end

  def idigbio_match_found?
    return false unless occurrence_id_valid?
    return ((idigbio_occurrence_id_results[:status] == :success) && (idigbio_occurrence_id_results[:data].length > 0))
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

    def prepare_and_create_taxonomy(params)
      attributes_for_actor = Hyrax::TaxonomyForm.model_attributes(params)
      attributes_for_actor.merge!({ visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC })
      curation_concern = Taxonomy.new
      env = Hyrax::Actors::Environment.new(curation_concern, Ability.new(User.find_by_ms_id(self.depositor)), attributes_for_actor)
      Hyrax::CurationConcern.actor.create(env)
      return curation_concern.id
    end

    def date_attributes_for_filter
      [ :date_created ]
    end

    def controlled_attributes
      { :sex => Morphosource::SexFieldService.new }
    end

end
