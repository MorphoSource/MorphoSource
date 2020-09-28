# Search builder for items in current user's media cart (cart items with downloaded = false)
module Morphosource
  module Catalog
    class ChildMediaSearchBuilder < ::SearchBuilder
      # include Hyrax::FilterByType

      self.default_processor_chain += [:show_only_accessible_child_media]

      def only_works?
        true
      end

      def show_only_accessible_child_media(solr_parameters)
        byebug
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] += [
          ActiveFedora::SolrQueryBuilder.construct_query_for_ids(@child_media_ids)
        ]
      end
    end
  end
end
