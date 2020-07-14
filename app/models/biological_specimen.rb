class BiologicalSpecimen < Morphosource::Works::Base

  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator

  self.indexer = BiologicalSpecimenIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [ImagingEvent, Attachment]

  validates :title, presence: { message: I18n.t('morphosource.validation.missing.title') }
  validates :vouchered, presence: { message: I18n.t('morphosource.validation.missing.vouchered')}

  include Morphosource::PhysicalObjectMetadata
  include Morphosource::BiologicalSpecimenMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

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
    member_of.select{|work| work.class == Taxonomy}
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

  # does not include the canonical taxonomy
  # any taxonomy that is not trusted
  def user_taxonomies
    other_taxonomies.reject{|taxonomy| taxonomy.trusted == ["Yes"]}
  end

  def organizations
    member_of.select{|work| work.class == Organization}
  end

  def media
    descendants.select{ |d| d.class == Media }
  end

  private
    def add_id_to_title # this is non-functional!!
      unless self.title && self.id && self.title.first.to_s.start_with?("S#{self.id.to_s}: ")
        self.title.set("S#{self.id.to_s}: #{self.title.first.to_s}")
      end
    end

    def update_metadata_from_idigbio_occurrence_id
      idigbio_occurrence_id_results = Morphosource::IDigBio.search({'occurrenceid' => self.occurrence_id.first})
      if idigbio_occurrence_id_results && (idigbio_occurrence_id_results.length > 0)
        idigbio_occurrence = idigbio_occurrence_id_results.first
        idb_taxonomy_params = Morphosource::IDigBioSearchService.taxonomy_params_from_idigbio(idigbio_occurrence['uuid'])
        existing_bso = Morphosource::PhysicalObjectsSearchService.call(BiologicalSpecimen, idb_taxonomy_params.clone)
        if (!existing_bso.nil?) && existing_bso.any?
          self.canonical_taxonomy = [ existing_bso.first.canonical_taxonomy.present? ? existing_bso.first.canonical_taxonomy.first : existing_bso.first.taxonomies.first.id ]
        else
          # we need to create the taxonomy here and set it as the canonical_taxonomy for this work
          taxonomy_model_params = Hyrax::TaxonomyForm.model_attributes(ActionController::Parameters.new(idb_taxonomy_params))
          new_taxonomy = Taxonomy.new
          attributes_for_actor = taxonomy_model_params
          attributes_for_actor.merge!({ visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC })
          env = Hyrax::Actors::Environment.new(new_taxonomy, Ability.new(User.find_by_ms_id(self.depositor)), attributes_for_actor)
          Hyrax::CurationConcern.actor.create(env)
          new_taxonomy = create_work(Taxonomy, taxonomy_model_params)
          self.canonical_taxonomy = [ new_taxonomy.id ]
        end
        # set the taxonomy to the canonical taxonomy
        self.work_parents_attributes = { '1' => { "id" => self.canonical_taxonomy.first, "_destroy" => "false" } }
        biospec_model_params = Morphosource::IDigBioSearchService.biological_specimen_params_from_idigbio(idigbio_occurrence['uuid'])
        biospec_model_params.each do |key, value|
          self.send("#{key}=", value.is_a?(Array) ? value : [value] )
        end
      end
    end
end
