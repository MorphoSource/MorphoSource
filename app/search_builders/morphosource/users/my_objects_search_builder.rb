# Retrieves all objects associated with media for which a user has edit access or has been granted read access
module Morphosource
  module Users
    class MyObjectsSearchBuilder < Hyrax::WorksSearchBuilder

      delegate :repository, to: :scope

      self.default_processor_chain += [:apply_object_ids_filter]

      private

        def apply_object_ids_filter(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] << object_ids_filter
        end

        def object_ids_filter
          "(id:(#{object_ids.join(' OR ')}))"
        end

        def object_ids
          ids = my_media.response['docs'].map { |d| d["physical_object_id_ssim"].first }
          ids.blank? ? ['none'] : ids
        end

        def my_media
          repository.blacklight_config.max_per_page = 999999
          repository.search(Morphosource::Users::MyMediaSearchBuilder.new(@scope).rows(999999).query)
        end

    end
  end
end
