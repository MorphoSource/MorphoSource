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

  def managers
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

  def dashboard_media_path
    Rails.application.routes.url_helpers.dashboard_media_list_media_path(self)
  end

  def dashboard_specimens_path
    Rails.application.routes.url_helpers.dashboard_media_list_specimens_path(self)
  end

  def dashboard_chos_path
    Rails.application.routes.url_helpers.dashboard_media_list_chos_path(self)
  end

  def dashboard_about_path
    Rails.application.routes.url_helpers.dashboard_media_list_about_path(self)
  end


  # get 'media_lists/:id', to: 'media_lists#edit', as: 'dashboard_media_list_media'
  # get 'media_lists/:id/biological_specimens', to: 'biological_specimens#show', as: 'dashboard_media_list_specimens'
  # get 'media_lists/:id/cultural_heritage_objects', to: 'cultural_heritage_objects#show', as: 'dashboard_media_list_chos'
  # get 'media_lists/:id/about', to: 'media_lists#about', as: 'dashboard_media_list_about'
  # get 'media_lists/:collection_id/facet/:id', to: 'media_lists#facet', as: 'dashboard_media_list_media_facet'
  # get 'media_lists/:collection_id/biological_specimens/facet/:id', to: 'biological_specimens#facet', as: 'dashboard_media_list_specimens_facet'
  # get 'media_lists/:collection_id/cultural_heritage_objects/facet/:id', to: 'cultural_heritage_objects#facet', as: 'dashboard_media_list_chos_facet'

  private

    # def add_depositor_to_managers
    #   user = User.find_by(ms_id: depositor)
    #   creators_group.users << user
    #   creators_group.save
    # end
end
