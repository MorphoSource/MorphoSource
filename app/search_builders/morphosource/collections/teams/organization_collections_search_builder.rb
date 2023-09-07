module Morphosource
  module Collections
    module Teams
      # Search for collections with org media, using @org_media_collection_ids
      # Does not filter by user access
      class OrganizationCollectionsSearchBuilder < Hyrax::WorksSearchBuilder

        delegate :repository, to: :scope

        self.default_processor_chain += [:apply_collection_ids_filter]

        # Return all collections regardless of user access permissions.
        self.default_processor_chain -= [:add_access_controls_to_solr_params]

        def initialize(*options)
          @org_media_collection_ids = options.first.instance_variable_get(:@org_media_collection_ids)
          super
        end

      def models
        [::Collection]
      end

        private

        def apply_collection_ids_filter(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] << collection_ids_filter
        end

        def collection_ids_filter
          "(id:(#{collection_ids.join(' OR ')}))"
        end

        def collection_ids
          @org_media_collection_ids.blank? ? ['none'] : @org_media_collection_ids
        end
      end
    end
  end
end
