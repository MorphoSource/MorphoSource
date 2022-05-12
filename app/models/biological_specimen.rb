class BiologicalSpecimen < Morphosource::Works::Base

  include ::Hyrax::WorkBehavior
  include Morphosource::PhysicalObjectBehavior
  validates_with Morphosource::ParentChildValidator
  before_create :controlled_value_filter
  before_update :controlled_value_filter
  after_update :reindex_media

  self.indexer = BiologicalSpecimenIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = []

  validates :title, presence: { message: I18n.t('morphosource.validation.missing.title') }

  include Morphosource::PhysicalObjectMetadata
  include Morphosource::BiologicalSpecimenMetadata
  include Morphosource::LocationMetadata

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

  def occurrence_id_valid? 
    # valid if 8 characters minimum AND has both a letter and a number
    occurrence_id.present? && occurrence_id.first.length >= 8 && 
      occurrence_id.first.count("0-9") > 0 && occurrence_id.first.count("a-zA-Z") > 0
  end

  def update_metadata_from_idigbio_occurrence_id(save_work=false)
    sex_field_values = Morphosource::SexFieldService.new().option_values
    if occurrence_id_valid?
      idigbio_occurrence_id_results = Morphosource::IDigBio.search({'occurrenceid' => self.occurrence_id.first})
      if idigbio_occurrence_id_results && (idigbio_occurrence_id_results.length > 0)
        idigbio_occurrence = idigbio_occurrence_id_results.first

        taxonomy_params_array = []
        taxonomy_id_array = []
        taxonomy_gbif_key_array = []
        canonical_taxonomy_id = nil

        idb_taxonomy_param_sets = Morphosource::IDigBioSearchService.taxonomy_param_sets_from_idigbio(idigbio_occurrence['uuid'])
        provider_params = idb_taxonomy_param_sets[:provider]
        gbif_params = idb_taxonomy_param_sets[:gbif]

        if provider_params.present?
          prov = Morphosource::TaxonomySearchService.call(provider_params)
          if prov.present?
            # Exists, link as canonical
            canonical_taxonomy_id = prov.first.id 
            taxonomy_id_array << prov.first.id
          else
            # Is new, must create            
            provider_params[:canonical] = true # to be hooked in later to set canonical taxonomy ID
            taxonomy_params_array << ActionController::Parameters.new(provider_params)
          end
        end

        if gbif_params.present?
          gbif = Morphosource::TaxonomySearchService.call(gbif_params)
          if gbif.present?
            taxonomy_id_array << gbif.first.id 
          else
            taxonomy_params_array << ActionController::Parameters.new(gbif_params)
          end
        end

        # add new taxonomy if any
        taxonomy_params_array.each do |taxon_params|
          new_taxon_id = prepare_and_create_taxonomy(taxon_params)
          taxonomy_id_array << new_taxon_id
          if taxon_params[:canonical]
            canonical_taxonomy_id = new_taxon_id 
          end
        end

        # now link taxonomy (new or existing) to the bso  
        if taxonomy_id_array.present?
          old_taxonomy_id = self.taxonomy_id.to_a
          self.taxonomy_id = (self.taxonomy_id + taxonomy_id_array).uniq
        end
        if canonical_taxonomy_id.present?
          old_canonical_taxonomy = self.canonical_taxonomy.to_a
          self.canonical_taxonomy_will_change! unless old_canonical_taxonomy.include? canonical_taxonomy_id 
          self.canonical_taxonomy = (self.canonical_taxonomy << canonical_taxonomy_id).uniq
        end

        if self.taxonomy_id_changed?
          Rails.logger.debug "UpdateBsoFromIdigbio: BSO #{id} : taxonomy_id #{old_taxonomy_id} will be updated to '#{self.taxonomy_id.to_a}'"
        end
        if self.canonical_taxonomy_changed?
          Rails.logger.debug "UpdateBsoFromIdigbio: BSO #{id} : canonical_taxonomy #{old_canonical_taxonomy} will be updated to '#{self.canonical_taxonomy.to_a}'"
        end

        # sync bso metadata
        biospec_model_params = Morphosource::IDigBioSearchService.biological_specimen_params_from_idigbio(idigbio_occurrence['uuid'])
        biospec_model_params.each do |key, value|
          if key == "sex"
            unless sex_field_values.include? value.capitalize
              # do not update the value from iDigBio unless it matches MS control list
              next
            end
          end
          self.send("#{key}=", value.is_a?(Array) ? value : [value] )
          field_changed = self.send("#{key}_changed?")
          if field_changed
            Rails.logger.debug "UpdateBsoFromIdigbio: BSO #{id} : #{key} field will be updated to '#{value}'"
          end
        end
        self.idigbio_link_origin = ["system_generated"]
        # normally saving work is done in a background job
        # set save_work flag if needed for debugging in the console
        self.save if save_work 
      end # / if idigbio_occurrence_id_results && (idigbio_occurrence_id_results.length > 0)
    end # / if occurrence_id_valid?
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

    def controlled_attributes
      { :sex => Morphosource::SexFieldService.new }
    end

end
