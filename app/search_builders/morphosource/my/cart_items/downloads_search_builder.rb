# Search builder current user's previously downloaded items (cart items with downloaded = true)
module Morphosource
  module My
    module CartItems

      class DownloadsSearchBuilder < ::SearchBuilder
        include Hyrax::FilterByType

        self.default_processor_chain += [:show_only_cart_items_downloaded_by_current_user]

        def only_works?
          true
        end

        def show_only_cart_items_downloaded_by_current_user(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] += [
            ActiveFedora::SolrQueryBuilder.construct_query_for_ids(current_user.downloaded_work_ids)
          ]
        end
      end
    end
  end
end
