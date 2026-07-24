class OrganizationCollection < Collection
  include Morphosource::OrganizationCollectionMetadata
  include Morphosource::OrganizationMetadata
  include Morphosource::PermissionsDefaultsMetadata
  include Morphosource::LocationMetadata
  include Morphosource::OrganizationBehavior
  include Morphosource::PersistentIdentifiersBehavior
  include Morphosource::Works::IndexRelatedWorks

  before_validation :normalize_download_reviewer
  before_save :convert_media_ownership_transfer
  before_save :record_date_managed
  after_create :create_collection_groups
  after_create :create_organization_project
  after_update :update_ark_status
  after_update :index_related_works
  after_create :mint_ark
  after_destroy :delete_ark_if_reserved

  self.indexer = OrganizationCollectionIndexer

  def search_builder_class
    Morphosource::Collections::MediaSearchBuilder
  end

  def initialize(params=nil)
    super
    self.collection_type_gid ||= collection_type.to_global_id
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

  def organization_collection?
    true
  end

  # Custom method to handle CarrierWave uploader
  def agreement_uploader
    @agreement_uploader ||= OrganizationCollectionAgreementAttachmentUploader.new.tap { |u| u.collection_id = id }
  end

  def is_device_organization?
    ["Scanning Facility", "Collection and Scanning Facility"].include?(organization_type&.first)
  end
  alias manages_devices? is_device_organization?

  def is_object_organization?
    ["Museum, Department, or Lab Collection", "Collection and Scanning Facility"].include?(organization_type&.first)
  end
  alias manages_objects? is_object_organization?

  def manages_objects_and_devices?
    organization_type&.first == "Collection and Scanning Facility"
  end

  def scanning_facility?
    organization_type&.first == "Scanning Facility"
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

  def team; end

  # return false for nil value
  def media_ownership_transfer?
    media_ownership_transfer ? true : false
  end

  def data_manager
    managers&.map(&:user_key) || []
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

  def can_manage_devices?
    organization_type&.first&.include?("Scanning Facility") || false
  end

  def devices_solr
    return [] if id.nil?

    qry = "organization_id_ssim:#{self.id}"
    ActiveFedora::SolrService.query(qry, fq: ["has_model_ssim:(Device OR DeviceResource)"], rows: 999999)
  end

  def devices
    return [] if id.blank?
    DeviceResource.where(organization_id: id)
  end

  # before_save callback to set date_managed if needed
  def record_date_managed
    return self.date_managed if self.managers.present? && self.date_managed.present?

    self.date_managed = self.managers.present? ? Date.today : nil
  end

  private

  # Organizations do not make their depositor a manager, so override the parent's
  # choice with the configured DEFAULT_ORGANIZATION_MANAGER (an ms_id). Seeding a
  # manager here guarantees every organization begins with at least one, closing
  # the edge case where org-mode download-reviewer resolution would have no
  # manager to resolve to. Returns nil, leaving the organization unmanaged, when
  # the setting is unset (e.g. test) or names a user that does not exist.
  def default_manager
    ms_id = Morphosource.default_organization_manager
    return if ms_id.blank? || ms_id == "NOT_SET"

    User.find_by(ms_id: ms_id).tap do |user|
      Rails.logger.warn("[OrganizationCollection] DEFAULT_ORGANIZATION_MANAGER '#{ms_id}' does not match any user; #{id} created without a manager") if user.blank?
    end
  end

  def create_organization_project
    project = example_organization_project
    project.create_collection_groups
    Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
    project.member_of_collections << self
    project.save!
    project
  end

  # Create a starter project for the organization
  def example_organization_project
    project_collection_type = Hyrax::CollectionType.where({:title => 'Project'})&.first
    project_title = [I18n.t('morphosource.dashboard.collections.organization_collection.example_project.title', title: title.first)]
    description = [I18n.t('morphosource.dashboard.collections.organization_collection.example_project.description')]
    project = Collection.create(title: project_title, collection_type_gid: project_collection_type.to_global_id, description: description, visibility: 'restricted', depositor: depositor)
  end

  # converts form values 'true' or 'false' to boolean
  def convert_media_ownership_transfer
    self.media_ownership_transfer = ActiveModel::Type::Boolean.new.cast(self.media_ownership_transfer)
  end
end
