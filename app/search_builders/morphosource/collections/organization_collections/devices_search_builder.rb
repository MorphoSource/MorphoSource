module Morphosource
  module Collections
    module OrganizationCollections
      class DevicesSearchBuilder < Morphosource::Catalog::DevicesCatalogSearchBuilder

        self.default_processor_chain += [:return_selected_fields, :filter_by_organization]

        # include filters into the query to only include the collection memebers
        def filter_by_organization(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] << "organization_id_ssim:#{@scope.collection.id}"
        end

        def return_selected_fields(solr_parameters)
          if !@blacklight_params[:return_all_fields]
            solr_parameters[:fl] = 'id,modality_tesim,title_ssi,creator_tesim,description_tesim'
          end
        end

      end
    end
  end
end
