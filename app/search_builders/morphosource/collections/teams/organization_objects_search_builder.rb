module Morphosource
  module Collections
    module Teams
      class OrganizationObjectsSearchBuilder < Hyrax::WorksSearchBuilder

        delegate :repository, to: :scope

        self.default_processor_chain += [:apply_object_ids_filter]

        def initialize(*options)
          @collection = options.first.instance_variable_get(:@collection)
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
            ids = media_object_ids
            ids.blank? ? ['none'] : ids
          end

          def media_object_ids
            repository.blacklight_config.max_per_page = 999999
            if @org_media_object_ids.present?
              @org_media_object_ids.map{|d| d["physical_object_id_ssim"].try(:first)}.compact.uniq
            else
              repository.search(Morphosource::Collections::Teams::OrganizationMediaSearchBuilder.new(@scope).rows(999999)).response["docs"].map{|d| d["physical_object_id_ssim"].try(:first)}.compact.uniq
            end
          end
        end
    end
  end
end
