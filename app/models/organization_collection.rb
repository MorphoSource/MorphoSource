class OrganizationCollection < Collection

  include Morphosource::OrganizationCollectionMetadata
  include Morphosource::OrganizationMetadata
  include Morphosource::PermissionsDefaultsMetadata
  include Morphosource::LocationMetadata

  after_create :create_collection_groups

  self.indexer = OrganizationCollectionIndexer

  def search_builder_class
    Morphosource::Collections::MediaSearchBuilder
  end

  def initialize(params=nil)
    super
    self.collection_type_gid = collection_type.gid
  end

  def self.collection_type
    Hyrax::CollectionType.find_by(Morphosource::CollectionTypes::Organizations::SETTINGS)
  end

  def collection_type
    self.class.collection_type
  end

  def human_readable_type
    'Organization'
  end

  def type_assigns_groups?
    true
  end

  def media_inherit_permissions?
    false
  end

  def organization
    self
  end

  def attachment(field_name)
    Morphosource::AttachmentService.get(self, field_name)
  end

  def name
    (institution_name + title).join(' - ')
  end
  alias display_name name

  def self.primary_key
    self.try(:id) || 'OrganizationCollection'
  end
end