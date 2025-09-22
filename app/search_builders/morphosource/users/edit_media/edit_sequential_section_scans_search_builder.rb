# retrieves all media with 'Sequential Section Scan' modality a user has edit access to, either through a role (collection member group), or as an individual
# filters by collection media object if collection is not empty
module Morphosource
  module Users
    module EditMedia
      class EditSequentialSectionScansSearchBuilder < Morphosource::Users::EditMediaSearchBuilder

        self.default_processor_chain += [:apply_modalities_filter, :apply_physical_object_id_filter]

        def modalities
          ["SequentialSectionScan"]
        end

        def apply_modalities_filter(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] << modalities_filter
        end

        def modalities_filter
          "(modality_ssim:(#{modalities.join(' OR ')}))"
        end

        # filter by physical object id of first media if collection is not empty
        def apply_physical_object_id_filter(solr_parameters)
          return unless physical_object_id

          solr_parameters[:fq] ||= []
          solr_parameters[:fq] << physical_object_id_filter
        end

        def physical_object_id_filter
          "(physical_object_id_tesim:(#{physical_object_id}))"
        end

        # nil if collection is empty
        def physical_object_id
          @media_object ||= media_object
          @physical_object_id ||= @media_object.blank? ? nil : @media_object.first["physical_object_id_tesim"].first
        end

        def media_object
          collection_id = self.scope.params["collection_id"]
          Morphosource::SolrService.new.get_docs("member_of_collection_ids_ssim:#{collection_id}", fl:"physical_object_id_tesim")
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
end