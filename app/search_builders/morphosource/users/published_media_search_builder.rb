# retrieves all published media 
module Morphosource
  module Users
    class PublishedMediaSearchBuilder < Hyrax::WorksSearchBuilder
      # filter_collection_facet_for_access
#      include Morphosource::Facets::CollectionsSearchBuilderBehavior
      # enable f.field facet format
#      include Morphosource::Facets::SearchBuilderFacetParamsBehavior

#      self.default_processor_chain -= [:add_access_controls_to_solr_params]
#      self.default_processor_chain += [:apply_read_edit_filters, :filter_collection_facet_for_access]

      def models
        [Media]
      end

    end
  end
end