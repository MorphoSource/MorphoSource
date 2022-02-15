module Morphosource
  module Collections
    module Teams
      # Search for collections with org media, using @org_media_collection_ids
      class OrganizationCollectionsSearchBuilder < Hyrax::WorksSearchBuilder

        delegate :repository, to: :scope

        self.default_processor_chain += [:apply_collection_ids_filter]

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
