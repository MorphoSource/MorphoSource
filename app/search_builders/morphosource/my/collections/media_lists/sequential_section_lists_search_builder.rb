module Morphosource
  module My
    module Collections
      module MediaLists
        class SequentialSectionListsSearchBuilder < Morphosource::My::Collections::MediaListsSearchBuilder

          def models
            [::Collection, SequentialSectionList]
          end

          def collection_types
            [Hyrax::CollectionType.find_by(title: "Sequential Section List")]
          end

          def add_facet_paging_to_solr(solr_params)
          super

          return unless facet.present?
            facet_config = blacklight_config.facet_fields[facet]
            contains = blacklight_params[blacklight_config.facet_paginator_class.request_keys[:contains]]
            if blacklight_params[blacklight_config.facet_paginator_class.request_keys[:contains]]
              solr_params[:"f.#{facet_config.field}.facet.contains"] = contains
              solr_params[:"f.#{facet_config.field}.facet.contains.ignoreCase"] = true
            end
          end

        end
      end
    end
  end
end