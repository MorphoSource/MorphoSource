# Search builder for items in current user's media cart (cart items with downloaded = false)
module Morphosource
  module My
    module CartItems

      class CartItemsSearchBuilder < ::SearchBuilder
        include Hyrax::FilterByType

        self.default_processor_chain += [:show_only_cart_items_owned_by_current_user]

        def only_works?
          true
        end

        def show_only_cart_items_owned_by_current_user(solr_parameters)
          solr_parameters[:fq] ||= []
          solr_parameters[:fq] += [
            ActiveFedora::SolrQueryBuilder.construct_query_for_ids(current_user.work_ids_in_cart)
          ]
        end
      end
    end
  end
end
