# Retrieves all objects associated with media for which a user has edit access or has been granted read access
module Morphosource
  module Users
    class MyObjectsSearchBuilder < Hyrax::WorksSearchBuilder
      # override filter_collection_facet_for_access
      include Morphosource::Facets::CollectionsSearchBuilderBehavior

      delegate :repository, to: :scope

      self.default_processor_chain += [:apply_object_ids_filter, :filter_collection_facet_for_access]

      private

        def apply_object_ids_filter(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] << object_ids_filter
        end

        def object_ids_filter
          "(id:(#{object_ids.join(' OR ')}))"
        end

        def object_ids
          ids = my_media_object_ids
          ids.blank? ? ['none'] : ids
        end

        def my_media_object_ids
          repository.blacklight_config.max_per_page = 999999
          repository.search(Morphosource::Users::MyMediaObjectsSearchBuilder.new(@scope).rows(999999).query).response['docs'].map { |d| d["physical_object_id_ssim"].try(:first) }.compact
        end

        def models
          [BiologicalSpecimen, CulturalHeritageObject]
        end

    end
  end
end
