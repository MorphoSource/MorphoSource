module Morphosource
  module Dashboard
    class NestedCollectionsSearchBuilder < Hyrax::Dashboard::NestedCollectionsSearchBuilder

      self.default_processor_chain -= [:show_only_other_collections_of_the_same_collection_type]

      self.default_processor_chain += [:show_only_projects, :show_only_parentless_collections]

      def show_only_projects(solr_parameters)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] += [
          ActiveFedora::SolrQueryBuilder.construct_query(Collection.collection_type_gid_document_field_name => Hyrax::CollectionType.where(title: "Project").first.to_global_id)
        ]
      end

      def show_only_parentless_collections(solr_parameters)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] += ["-" + "nesting_collection__parent_ids_ssim:*"]
      end
    end
  end
end
