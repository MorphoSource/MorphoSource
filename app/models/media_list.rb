class MediaList < Collection
  after_create :create_collection_groups

  def initialize
    super
    self.collection_type_gid = collection_type.gid
  end

  DEFAULT_GROUP_ROLES = %w[creators curators visitors].freeze

  DEFAULT_GROUP_ROLES.each do |role|
    define_method("#{role}_group") do
      Role.find_by(name: id.concat("_#{role}"))
    end
  end

  DEFAULT_GROUP_ROLES.each do |role|
    define_method(role) do
      Role.find_by(name: id.concat("_#{role}")).users
    end
  end

  def collection_type
    Hyrax::CollectionType.find_by(machine_id: 'media_list')
  end

  def type_assigns_groups?
    true
  end

  def human_readable_type
    "Media List"
  end

  def user_groups
    [creators_group, curators_group, visitors_group]
  end

  def group_members
    creators + curators + visitors
  end

  # Create manager/depositor/viewer roles for each Team/Project collection
  def create_collection_groups
    DEFAULT_GROUP_ROLES.each do |role|
      Role.create(name: id.concat("_#{role}"))
    end
    add_depositor_to_creators
  end

  def membership_of(user)
    membership_list = []
    membership_list << 'Creator' if creators.include?(user)
    membership_list << 'Curator' if curators.include?(user)
    membership_list << 'Visitor' if visitors.include?(user)
    membership_list
  end

  private

    def add_depositor_to_creators
      user = User.find_by(ms_id: depositor)
      creators_group.users << user
      creators_group.save
    end
end
