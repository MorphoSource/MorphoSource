module Morphosource
  module My
    module Collections
      module MediaLists
        class SequentialSectionListsSearchBuilder < Morphosource::My::Collections::MediaListsSearchBuilder

          include Hyrax::My::SearchBuilderBehavior

          def models
            [::Collection, SequentialSectionList]
          end

          def collection_types
            [Hyrax::CollectionType.find_by(title: "Sequential Section List")]
          end

          # Sort results by title if no query was supplied.
          # This overrides the default 'relevance' sort.
          def add_sorting_to_solr(solr_parameters)
            return if solr_parameters[:q]
            solr_parameters[:sort] ||= sort
            solr_parameters[:sort] ||= "#{sort_field} asc"
          end

        end
      end
    end
  end
end