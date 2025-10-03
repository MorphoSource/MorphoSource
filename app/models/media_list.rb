class MediaList < Collection
  include Morphosource::MediaListMetadata
  include Morphosource::DoiBehavior

  self.indexer = MediaListIndexer

  after_create :create_collection_groups
  before_destroy :prevent_doi_deletion

  DEFAULT_GROUP_ROLES = %w[managers viewers].freeze

  def initialize(params=nil)
    super
    self.collection_type_gid = collection_type.to_global_id
  end

  def self.collection_type
    Hyrax::CollectionType.find_by(Morphosource::CollectionTypes::MediaLists::SETTINGS)
  end

  def collection_type
    self.class.collection_type
  end

  def presenter_class
    Morphosource::Collections::MediaListPresenter
  end

  def search_builder_class
    Morphosource::Users::AddToMediaListSearchBuilder
  end

  def list?
    true
  end

  def media_list?
    true
  end

  def type_assigns_groups?
    true
  end

  def human_readable_type
    "Media List"
  end

  def user_groups
    [managers_group, viewers_group]
  end

  def group_members
    managers + viewers
  end

  def membership_of(user)
    membership_list = []
    membership_list << 'Manager' if managers.include?(user)
    membership_list << 'Viewer' if viewers.include?(user)
    membership_list
  end

end
