class MediaList < Collection
  include Morphosource::MediaListMetadata

  after_create :create_collection_groups

  DEFAULT_GROUP_ROLES = %w[managers viewers].freeze

  def self.collection_type
    Hyrax::CollectionType.find_by(machine_id: 'media_list')
  end

  def presenter_class
    Morphosource::Collections::MediaListPresenter
  end

  def list?
    true
  end

  def initialize(params=nil)
    super
    self.collection_type_gid = collection_type.gid
  end

  def collection_type
    self.class.collection_type
  end

  def type_assigns_groups?
    true
  end

  def apply_collection_permissions?
    false
  end

  def human_readable_type
    "Media List"
  end
end
