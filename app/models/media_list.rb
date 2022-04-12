class MediaList < Collection
  after_create :create_collection_groups

  def self.collection_type
    Hyrax::CollectionType.find_by(machine_id: 'media_list')
  end

  def list?
    true
  end

  def initialize(params=nil)
    super
    self.collection_type_gid = collection_type.gid
  end

  DEFAULT_GROUP_ROLES = %w[managers].freeze

  def managers_group
    Role.find_by(name: id.concat("_managers"))
  end

  def curators
    Role.find_by(name: id.concat("_managers")).users
  end

  def collection_type
    self.class.collection_type
  end

  def type_assigns_groups?
    true
  end

  def human_readable_type
    "Media List"
  end

  def user_groups
    [managers_group]
  end

  def group_members
    managers
  end

  # Create manager/depositor/viewer roles for each Team/Project collection
  def create_collection_groups
    Role.create(name: id.concat("_managers"))
    add_depositor_to_managers
  end

  def membership_of(user)
    membership_list = []
    membership_list << 'Manager' if managers.include?(user)
    membership_list
  end

  private

    # def add_depositor_to_managers
    #   user = User.find_by(ms_id: depositor)
    #   creators_group.users << user
    #   creators_group.save
    # end
end
