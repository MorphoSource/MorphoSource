module Morphosource
  class PhysicalObjectMediaSearchService
    attr_reader :context

    class_attribute :list_search_builder_class
    self.list_search_builder_class = Morphosource::PhysicalObjectMediaSearchBuilder

    # @param [#repository,#blacklight_config,#current_ability] context
    def initialize(context, object_id)
      @object_id = object_id
      @context = context
    end

    # @param [Symbol] access :read or :edit
    def search_results
      builder = list_search_builder
      repository = MediaCatalogController.new.repository
      response =  repository.search(builder)
      response.documents
    end

    private

      def list_search_builder
        list_search_builder_class.new(scope: @context, object_id: @object_id)
                                 .rows(999999)

      end
  end
end
