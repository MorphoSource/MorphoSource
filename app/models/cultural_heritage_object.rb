class CulturalHeritageObject < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  include ::Morphosource::PhysicalObjectBehavior
  include Morphosource::PersistentIdentifiersBehavior
  validates_with Morphosource::ParentChildValidator
  after_update :reindex_media, :update_ark_status
  after_create :mint_ark
  # prepend: true -- must run before any other before_destroy callback (e.g.
  # Hydra::AccessControls::Permissions destroys the record's access_control resource
  # unconditionally in its own before_destroy, registered earlier via an earlier include).
  # Without prepend, aborting here still lets earlier-registered callbacks' side effects
  # through, since throw :abort only stops what hasn't run yet.
  before_destroy :prevent_destroy_with_media, prepend: true
  after_destroy :delete_ark_if_reserved

  self.indexer = CulturalHeritageObjectIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = []

  validates :title, presence: { message: I18n.t('morphosource.validation.missing.title') }
  validates :vouchered, presence: { message: I18n.t('morphosource.validation.missing.vouchered')}

  include Morphosource::PhysicalObjectMetadata
  include Morphosource::LocationMetadata
  include ::Morphosource::BasicMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include Morphosource::CulturalHeritageObjectMetadata

  def taxonomies # TODO remove later after refactoring media_indexer
    []
  end

  def taxonomies_titles # TODO remove later after refactoring media_indexer
    []
  end


  private

    def reindex_media
      # reindex media is needed when certain PO fields have been changed
      if self.title_changed?
        self.media.each do |media|
          UpdateWorkIndexJob.perform_later(media.id)
        end
      end
    end

end
