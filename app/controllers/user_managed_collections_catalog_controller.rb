class UserManagedCollectionsCatalogController < ::CollectionsCatalogController

  def index
    blacklight_config.search_builder_class = Morphosource::Users::ManagedCollectionsSearchBuilder
    super
  end

  def user
    User.find_by(ms_id: params["user"])
  end

end

