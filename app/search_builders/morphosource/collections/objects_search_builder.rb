module Morphosource
  module Collections
    class ObjectsSearchBuilder < Hyrax::WorksSearchBuilder

      delegate :repository, to: :scope

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
          if @collection.organization.present?
            "(id:(#{object_ids.join(' OR ')}) OR organization_id_ssim:#{@collection.organization&.id})"
          else
            "(id:(#{object_ids.join(' OR ')}))"
          end
        end

        def object_ids
          ids = media_object_ids
          ids.blank? ? ['none'] : ids
        end

        def media_object_ids
          repository.blacklight_config.max_per_page = 999999
          if @media_list.present?
            @media_list.map{|d| d["physical_object_id_ssim"].try(:first)}.compact.uniq
          else
            repository.search(Morphosource::Collections::MediaObjectsSearchBuilder.new(scope: @scope, collection: @collection).rows(999999)).response["docs"].map{|d| d["physical_object_id_ssim"].try(:first)}.compact.uniq
          end
        end

    end
  end
end
