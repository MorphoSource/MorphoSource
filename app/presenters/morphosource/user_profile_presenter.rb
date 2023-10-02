module Morphosource
  class UserProfilePresenter < Hyrax::UserProfilePresenter

    # returns the number of collections managed by @user viewable by @current_user
    def managed_collection_count
      search_builder = Morphosource::Users::ManagedCollectionsSearchBuilder.new(self)
      repository.search(search_builder.query).response["numFound"]
    end

    def deposited_media_count
    end

    def managed_media_count
    end

    def user
      @user
    end

    alias current_ability ability

    private

      def repository
        catalog_controller = CollectionsCatalogController.new
        catalog_controller.instance_variable_set(:@current_ability, @ability)
        catalog_controller.repository
      end
  end
end