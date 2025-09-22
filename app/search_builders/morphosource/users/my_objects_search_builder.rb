# Retrieves all objects associated with media for which a user has edit access or has been granted read access
module Morphosource
  module Users
    class MyObjectsSearchBuilder < Hyrax::WorksSearchBuilder
      include Morphosource::SearchBuilderBehavior
      # override filter_collection_facet_for_access
      include Morphosource::Facets::CollectionsSearchBuilderBehavior
      # enable f.field facet format
      include Morphosource::Facets::SearchBuilderFacetParamsBehavior

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

        def add_facet_paging_to_solr(solr_params)
        super

        return unless facet.present?
          facet_config = blacklight_config.facet_fields[facet]
          contains = blacklight_params[blacklight_config.facet_paginator_class.request_keys[:contains]]
          if blacklight_params[blacklight_config.facet_paginator_class.request_keys[:contains]]
            solr_params[:"f.#{facet_config.field}.facet.contains"] = contains
            solr_params[:"f.#{facet_config.field}.facet.contains.ignoreCase"] = true
          end
        end

    end
  end
end
