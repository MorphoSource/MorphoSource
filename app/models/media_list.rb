class MediaList < Collection
  include Morphosource::MediaListMetadata

  after_create :create_collection_groups

  DEFAULT_GROUP_ROLES = %w[managers viewers].freeze

  def initialize(params=nil)
    super
    self.collection_type_gid = collection_type.gid
  end

  def self.collection_type
    Hyrax::CollectionType.find_by(machine_id: 'media_list')
  end

  def collection_type
    self.class.collection_type
  end

  def presenter_class
    Morphosource::Collections::MediaListPresenter
  end

  def list?
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
