class OrganizationCollection < Collection

  include Morphosource::OrganizationCollectionMetadata
  include Morphosource::OrganizationMetadata
  include Morphosource::PermissionsDefaultsMetadata
  include Morphosource::LocationMetadata

  after_create :create_collection_groups
  after_create :create_organization_project

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

  def email
    managers.map(&:email)
  end

  def proxy_deposit_requests
    ProxyDepositRequest.where(receiving_user_id: id)
  end

  # used by ProxyDepositRequest
  def self.primary_key
    "id"
  end

  # used by ProxyDepositRequest
  # goes in receiving_user_type
  def self.polymorphic_name
    "OrganizationCollection"
  end
  private

    def create_organization_project
      project = example_organization_project
      project.create_collection_groups
      project.member_of_collections << self
      project.save!
      project
    end

    # Create a starter project for the organization
    def example_organization_project
      project_collection_type = Hyrax::CollectionType.where({:title => 'Project'})&.first
      project_title = [I18n.t('morphosource.dashboard.collections.organization_collection.example_project.title', title: title.first)]
      description = [I18n.t('morphosource.dashboard.collections.organization_collection.example_project.description')]
      project = Collection.create(title: project_title, collection_type_gid: project_collection_type.gid, description: description, visibility: 'restricted', depositor: depositor)
    end
end