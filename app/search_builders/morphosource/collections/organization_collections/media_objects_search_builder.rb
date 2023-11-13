module Morphosource
  module Collections
    module OrganizationCollections
      class MediaObjectsSearchBuilder < Morphosource::Collections::OrganizationCollections::MediaSearchBuilder

        # include Morphosource::OrganizationalAccessBehavior

        self.default_processor_chain -= [:default_solr_parameters, :add_query_to_solr, :add_facet_fq_to_solr, :add_facetting_to_solr, :add_solr_fields_to_query, :add_sorting_to_solr, :add_group_config_to_solr, :add_facet_paging_to_solr]

        def return_selected_fields(solr_parameters)
          solr_parameters[:fl] = 'physical_object_id_ssim'
        end

        # def apply_organization_permissions?
        #   false
        # end

      end
    end
  end
end
