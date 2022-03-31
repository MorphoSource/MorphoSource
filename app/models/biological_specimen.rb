class BiologicalSpecimen < Morphosource::Works::Base

  include ::Hyrax::WorkBehavior
  include Morphosource::PhysicalObjectBehavior
  validates_with Morphosource::ParentChildValidator
  after_update :reindex_media

  self.indexer = BiologicalSpecimenIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = []

  validates :title, presence: { message: I18n.t('morphosource.validation.missing.title') }

  include Morphosource::PhysicalObjectMetadata
  include Morphosource::BiologicalSpecimenMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  # :occurrence_id_changed? may change to :will_save_change_to_occurrence_id?
  # if ActiveFedora updates to reflect the Rails 5.1+ ActiveRecord/ActiveModel API
  # Temporarily removing this because we're not sure if we want specimens to auto-update on change
  # before_update :update_metadata_from_idigbio_occurrence_id, if: :occurrence_id_changed?

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

  def update_metadata_from_idigbio_occurrence_id
    # Occurrence ID less than 10 characters should be ignored
    if self.occurrence_id.present? && self.occurrence_id.first.length > 10 
      idigbio_occurrence_id_results = Morphosource::IDigBio.search({'occurrenceid' => self.occurrence_id.first})
      if idigbio_occurrence_id_results && (idigbio_occurrence_id_results.length > 0)
        idigbio_occurrence = idigbio_occurrence_id_results.first
#        idb_taxonomy_params = Morphosource::IDigBioSearchService.taxonomy_param_sets_from_idigbio(idigbio_occurrence['uuid'])
        #idb_taxonomy_params = Morphosource::IDigBioSearchService.taxonomy_param_sets_from_idigbio(idigbio_occurrence['uuid'])[:gbif]

#        existing_bso = Morphosource::PhysicalObjectsSearchService.call(BiologicalSpecimen, idb_taxonomy_params.clone)
#        if (!existing_bso.nil?) && existing_bso.any?
#  byebug
#          self.canonical_taxonomy = [ existing_bso.first.canonical_taxonomy.present? ? existing_bso.first.canonical_taxonomy.first : existing_bso.first.taxonomies.first.id ]
#        else
          # we need to create the taxonomy here and set it as the canonical_taxonomy for this work
#  byebug
#            taxonomy_model_params = Hyrax::TaxonomyForm.model_attributes(ActionController::Parameters.new(idb_taxonomy_params))
#            new_taxonomy = Taxonomy.new
#            attributes_for_actor = taxonomy_model_params
#            attributes_for_actor.merge!({ visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC })
#            env = Hyrax::Actors::Environment.new(new_taxonomy, Ability.new(User.find_by_ms_id(self.depositor)), attributes_for_actor)
#            Hyrax::CurationConcern.actor.create(env)
#            new_taxonomy = create_work(Taxonomy, taxonomy_model_params)
#            self.canonical_taxonomy = [ new_taxonomy.id ]
#  byebug
#        end

        # set the taxonomy to the canonical taxonomy
  #        self.taxonomy_id = self.taxonomy_id + [ self.canonical_taxonomy.first ] unless self.taxonomy_id.include?(self.canonical_taxonomy.first)

        ##  
        biospec_model_params = Morphosource::IDigBioSearchService.biological_specimen_params_from_idigbio(idigbio_occurrence['uuid'])
        biospec_model_params.each do |key, value|
          self.send("#{key}=", value.is_a?(Array) ? value : [value] )
          field_changed = self.send("#{key}_changed?")
          if field_changed
            Rails.logger.debug "UpdateBsoFromIdigbio: BSO #{id} : #{key} field will be updated to '#{value}'"
          end
        end
      end
    end # / if occurrence_id > 10 char
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

end
