module Morphosource
  module Collections
    class ObjectsSearchBuilder < Hyrax::WorksSearchBuilder

      delegate :repository, to: :scope

      self.default_processor_chain += [:apply_object_ids_filter]

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

        def object_ids
          @object_ids.blank? ? ['none'] : @object_ids
        end

    end
  end
end
