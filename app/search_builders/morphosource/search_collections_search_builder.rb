# Search all collections, including Media and Sequential Section Scan Lists, that the user has a particular access to
module Morphosource
  class SearchCollectionsSearchBuilder < Hyrax::CollectionSearchBuilder
    include Hyrax::FilterByType

    attr_reader :access

    def initialize(scope: nil, blacklight_config: nil, current_ability: nil)
      @current_ability = current_ability
      super
    end

    def collection_classes
      [Collection, MediaList, SequentialSectionList]
    end

    def blacklight_config
      CatalogController.blacklight_config
    end

    def current_ability
      @current_ability
    end

    def with_access(access)
      @access = access
      super(access)
    end

    def collection_ids_for_deposit
      Hyrax::Collections::PermissionsService.collection_ids_for_deposit(ability: current_ability)
    end

  end
end