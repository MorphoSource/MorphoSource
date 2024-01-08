module Hyrax
  class MediaListsService
    attr_reader :context

    class_attribute :list_search_builder_class
    self.list_search_builder_class = Hyrax::MediaLists

    # @param [#repository,#blacklight_config,#current_ability] context
    def initialize(context)
      @context = context
    end

    # @param [Symbol] access :read or :edit
    def search_results(access)
      builder = list_search_builder(access)
      response = context.repository.search(builder)
      response.documents
    end

    private

      def list_search_builder(access)
        list_search_builder_class.new(context)
                                 .rows(999999)
                                 .with_access(access)
      end
  end
end
