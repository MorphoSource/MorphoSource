module Morphosource
  module Dashboard
    class NestedCollectionsSearchBuilder < Hyrax::Dashboard::NestedCollectionsSearchBuilder

      self.default_processor_chain -= [:show_only_other_collections_of_the_same_collection_type]

      # self.default_processor_chain += [:show_only_projects, :show_only_parentless_collections]

      def show_only_projects(solr_parameters)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] += [
          Hyrax::SolrQueryBuilderService.construct_query(
            Hyrax.config.collection_type_index_field =>
              Hyrax::CollectionType.where(title: "Project").first.to_global_id.to_s
          )
        ]
      end

      def show_only_parentless_collections(solr_parameters)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] += ["-" + "member_of_collection_ids_ssim:*"]
      end

      def models
        super + [OrganizationCollection]
      end

    end
  end
end
