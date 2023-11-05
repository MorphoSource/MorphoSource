module Morphosource
  module Collections
    class ChosCountSearchBuilder < Morphosource::Collections::ChosSearchBuilder
      include Hyrax::FilterByType

      self.default_processor_chain -= [:default_solr_parameters, :add_query_to_solr, :add_facet_fq_to_solr, :add_facetting_to_solr, :add_solr_fields_to_query, :add_sorting_to_solr, :add_group_config_to_solr, :add_facet_paging_to_solr]

      self.default_processor_chain += [:return_ids]

      def return_ids(solr_parameters)
        solr_parameters[:fl] = 'id'
      end

      def apply_organization_permissions?
        false
      end

    end
  end
end
