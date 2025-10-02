class UserManagedCollectionsCatalogController < ::CollectionsCatalogController
  # Used to view the collections catalog filtered for collections that are editable by @user and viewable by @current_user

  def index
    @user = user
    blacklight_config.user = @user
    blacklight_config.search_builder_class = Morphosource::Users::ManagedCollectionsSearchBuilder
    super
  end

  def user
    User.find_by(ms_id: params["user"])
  end
end

