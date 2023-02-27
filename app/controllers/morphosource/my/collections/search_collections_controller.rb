module Morphosource
  module My
    module Collections
      class SearchCollectionsController < Hyrax::MyController

        def search_builder_class
          Morphosource::SearchCollectionsSearchBuilder
        end

        def search
          (@response, @document_list) = query_solr
        end

        private

        def search_builder
          search_builder_class.new(scope: self, blacklight_config: self.blacklight_config, current_ability: current_ability).with_access(:deposit)
        end

      end
    end
  end
end