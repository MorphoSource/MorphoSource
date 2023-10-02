module Morphosource
  class UserProfilePresenter < Hyrax::UserProfilePresenter

    # returns the number of collections managed by @user viewable by @current_user
    def managed_collection_count
      search_builder = Morphosource::Users::ManagedCollectionsSearchBuilder.new(self)
      repository.search(search_builder.query).response["numFound"]
    end

    # returns the number of media deposited by @user viewable by @current_user
    def deposited_media_count
      search_builder = Morphosource::Users::DepositedMediaSearchBuilder.new(self)
      repository.search(search_builder.query).response["numFound"]
    end

    # returns the number of media managed by @user viewable by @current_user
    def managed_media_count
      search_builder = Morphosource::Users::ManagedMediaSearchBuilder.new(self)
      repository.search(search_builder.query).response["numFound"]
    end

    def user
      @user
    end

    alias current_ability ability

    private

      def repository
        catalog_controller = CatalogController.new
        catalog_controller.instance_variable_set(:@current_ability, @ability)
        catalog_controller.repository
      end
  end
end