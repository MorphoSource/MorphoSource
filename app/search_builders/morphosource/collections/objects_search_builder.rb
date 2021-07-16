# Retrieves all objects associated with media for which a user has edit access or has been granted read access
module Morphosource
  module Collections
    class ObjectsSearchBuilder < Hyrax::WorksSearchBuilder

      delegate :repository, to: :scope
      # delegate :blacklight_config, to: Hyrax::CollectionsController

      self.default_processor_chain += [:apply_object_ids_filter]

      def initialize(*options)
        @collection = options.first.instance_variable_get(:@collection)
        @media_list = options.first.instance_variable_get(:@media_list)
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
          ids = media_object_ids
          ids.blank? ? ['none'] : ids
        end

        def media_object_ids
          @media_list.map { |d| d["physical_object_id_ssim"].try(:first) }.compact
        end

    end
  end
end
