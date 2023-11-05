module Morphosource
  module Collections
    class ObjectsSearchBuilder < Hyrax::WorksSearchBuilder
      # override filter_collection_facet_for_access
      include Morphosource::Facets::CollectionsSearchBuilderBehavior
      include Morphosource::OrganizationalAccessBehavior


      delegate :repository, to: :scope

      self.default_processor_chain += [:apply_object_ids_filter, :filter_collection_facet_for_access]

      def initialize(*options)
        @collection = options.first.instance_variable_get(:@collection)
        @object_ids = options.first.instance_variable_get(:@object_ids)
        super
      end

      private

        def apply_object_ids_filter(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] << object_ids_filter
        end

        def object_ids_filter
          "(id:(#{object_ids.join(' OR ')}))"
        end

        # @object_ids supplied by collection_media method in collections_controller_behavior
        def object_ids
          @object_ids.blank? ? ['none'] : @object_ids
        end

    end
  end
end
