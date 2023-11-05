module Morphosource
  module Collections
    module Teams
      class OrganizationMediaSearchBuilder < Morphosource::Catalog::MediaCatalogSearchBuilder

        delegate :repository, to: :scope

        self.default_processor_chain += [:apply_organization_filter, :return_object_ids]

        def initialize(*options)
          @organization = options.first.instance_variable_get(:@organization)
          super
        end

        private

          def return_object_ids(solr_parameters)
            solr_parameters[:fl] = 'physical_object_id_ssim'
          end

          def apply_organization_filter(solr_parameters)
            solr_parameters[:fq] ||= []
            solr_parameters[:fq] << "(media_organization_id_ssim:#{@organization.id})"
          end

          def apply_organization_permissions?
            false
          end
       end
     end
   end
end
