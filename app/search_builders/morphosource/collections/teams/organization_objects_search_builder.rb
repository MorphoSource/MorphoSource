module Morphosource
  module Collections
    module Teams
      class OrganizationObjectsSearchBuilder < Hyrax::WorksSearchBuilder

        include Morphosource::OrganizationalAccessBehavior

        delegate :repository, to: :scope

        self.default_processor_chain += [:apply_object_ids_filter]

        def initialize(*options)
          @org_media_object_ids = options.first.instance_variable_get(:@org_media_object_ids)
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
            @org_media_object_ids.blank? ? ['none'] : @org_media_object_ids
          end
        end
    end
  end
end
