module Morphosource
  class UserProfilePresenter < Hyrax::UserProfilePresenter

    def managed_collection_count
      catalog_controller = CollectionsCatalogController.new
      catalog_controller.instance_variable_set(:@current_ability, @ability)
      repository = catalog_controller.repository
      search_builder = Morphosource::Users::ManagedCollectionsSearchBuilder.new(catalog_controller)
      byebug
      search_builder.instance_variable_set(:@user, @user)
      repository.search(search_builder.query).response["numFound"]
    end

    def deposited_work_count
    end

    def managed_work_count
    end
  end
end