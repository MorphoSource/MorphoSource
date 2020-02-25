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

end
