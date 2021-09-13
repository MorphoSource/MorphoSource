module Morphosource
  module Collections
    class MediaObjectsSearchBuilder < Morphosource::Collections::MediaSearchBuilder

      self.default_processor_chain -= [:default_solr_parameters, :add_query_to_solr, :add_facet_fq_to_solr, :add_facetting_to_solr, :add_solr_fields_to_query, :add_sorting_to_solr, :add_group_config_to_solr, :add_facet_paging_to_solr]

      self.default_processor_chain += [:return_object_ids]

      def return_object_ids(solr_parameters)
        solr_parameters[:fl] = 'physical_object_id_ssim'
      end

    end
  end
end
