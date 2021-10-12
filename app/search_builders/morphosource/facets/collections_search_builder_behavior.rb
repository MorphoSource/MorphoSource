module Morphosource
  module Facets
    module CollectionsSearchBuilderBehavior

      # search_builder method to only return facet counts for collections that this user has access to see
      # override hyrax method to include member_of_team_ids and member_of_project_ids
      # change facet.matches to facet.excludeTerms - facet.matches not available in solr 7.1
      # https://github.com/samvera/hyrax/blob/b034218b89dde7df534e32d1e5ade9161e129a1d/app/search_builders/hyrax/catalog_search_builder.rb#L53
      def filter_collection_facet_for_access(solr_parameters)
        return if current_ability.admin?

        filtered_ids = filtered_collection_ids

        if models.include? Media
          solr_parameters['f.member_of_collection_ids_ssim.facet.excludeTerms'] = filtered_ids
          solr_parameters['f.member_of_team_ids_ssim.facet.excludeTerms'] = filtered_ids
          solr_parameters['f.member_of_project_ids_ssim.facet.excludeTerms'] = filtered_ids
        elsif models.include?(BiologicalSpecimen) || models.include?(CulturalHeritageObject)
          solr_parameters['f.media_member_of_team_ids_ssim.facet.excludeTerms'] = filtered_ids
          solr_parameters['f.media_member_of_project_ids_ssim.facet.excludeTerms'] = filtered_ids
        end
      end

      def user_viewable_collection_ids
        Hyrax::Collections::PermissionsService.collection_ids_for_view(ability: current_ability)
      end

      def filtered_collection_ids
        restricted_collection_ids = Morphosource::SolrService.new.get_docs('has_model_ssim:Collection AND visibility_ssi:restricted', fl: 'id').map{|c| c["id"]}
        user_collection_ids = user_viewable_collection_ids
        (restricted_collection_ids - user_viewable_collection_ids).join(',')
      end
    end
  end
end
