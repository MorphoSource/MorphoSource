module Morphosource
  module Dashboard
    class MediaListsSearchBuilder < Hyrax::CollectionSearchBuilder
      include Hyrax::Dashboard::ManagedSearchFilters

      self.solr_access_filters_logic += [:apply_collection_creator_permissions, :apply_collection_curator_permissions, :apply_collection_visitor_permissions]
      self.default_processor_chain += [:show_only_managed_collections_for_non_admins]

      # This overrides the models in FilterByType
      def models
        [::MediaList]
      end

      def apply_media_list_permissions(_permission_types, _ability = current_ability)
        return [] if collection_ids.empty?
        ["{!terms f=id}#{collection_ids.join(',')}"]
      end


      # adds a filter to exclude collections and admin sets created by the
      # current user if the current user is not an admin.
      # @param [Hash] solr_parameters
      def show_only_managed_collections_for_non_admins(solr_parameters)
        return if current_ability.admin?
        clauses = [
          '-' + ActiveFedora::SolrQueryBuilder.construct_query_for_rel(depositor: current_user_key),
          '-' + ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: ::AdminSet.to_s, creator: current_user_key)
        ]
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] += ["(#{clauses.join(' OR ')})"]
      end


      private

        def collection_ids
          byebug
          current_ability.groups
          Morphosource::SolrService.get_docs("edit_groups")
        end
    end
  end
end
