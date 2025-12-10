class MediaList < Collection
  include Morphosource::MediaListMetadata
  include Morphosource::DoiBehavior

  self.indexer = MediaListIndexer

  before_create :assign_creator
  after_create :create_collection_groups
  before_validation :normalize_contributor
  # Prevent deletion if DOI exists
  before_destroy :prevent_doi_deletion

  DEFAULT_GROUP_ROLES = %w[managers viewers].freeze

  def initialize(params=nil)
    byebug
    super
    byebug
    self.collection_type_gid = collection_type.to_global_id
  end

  def self.collection_type
    Hyrax::CollectionType.find_by(Morphosource::CollectionTypes::MediaLists::SETTINGS)
  end

  def collection_type
    Hyrax::CollectionType.find_by(Morphosource::CollectionTypes::MediaLists::SETTINGS)
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

  # Convert ["ms_id1,ms_id2,ms_id3"] to ["ms_id1","ms_id2","ms_id3"]
  def normalize_contributor
    self.contributor = self.contributor.map { |x| x.split(',') }.flatten
  end

  # If no creator is assigned, set the depositor as the creator
  def assign_creator
    if self.creator.blank?
      self.creator = [self.depositor]
    end
  end
end