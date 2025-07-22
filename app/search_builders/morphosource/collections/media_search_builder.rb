module Morphosource
  module Collections
    class MediaSearchBuilder < Hyrax::CollectionMemberSearchBuilder
      include Morphosource::SearchBuilderBehavior
      # override filter_collection_facet_for_access
      include Morphosource::Facets::CollectionsSearchBuilderBehavior
      # enable f.field facet format
      include Morphosource::Facets::SearchBuilderFacetParamsBehavior

      self.default_processor_chain += [:return_selected_fields, :filter_collection_facet_for_access]

      def member_of_collection(solr_parameters)
        return unless collection.present?

        solr_parameters[:fq] ||= []
        # if collection is a team, get linked organization media
        if collection.team? && collection.organization.present?
          solr_parameters[:fq] << "(#{collection_membership_field}:(#{collection_ids.join(' OR ')}) OR media_organization_id_ssim:#{collection.organization&.id})"
        else
          solr_parameters[:fq] << "(#{collection_membership_field}:(#{collection_ids.join(' OR ')}))"
        end
      end

      def return_selected_fields(solr_parameters)
        if !@blacklight_params[:return_all_fields]
          solr_parameters[:fl] = 'id,has_model_ssim,title_tesim,thumbnail_path_ss,part_tesim,physical_object_title_ssim,taxonomy_ssim,human_readable_media_type_tesim,date_uploaded_dtsi,fileset_accessibility_ssim,short_description_ssim'
        end
      end

      def models
        [Media]
      end

      def collection_ids
        return [] unless collection
        [collection.id] + subcollection_ids
      end

      def subcollection_ids
        return [] unless collection && (collection.team? || collection.organization_collection?)

        subcollections.docs.map(&:id)
      end

      def subcollections
        Morphosource::Collections::CollectionMemberService.new(scope: scope, collection: collection, params: {}).available_member_subcollections
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

      private

      def discovery_permissions
        @discovery_permissions ||= ["edit","discover","download","read"]
      end

    end
  end
end
