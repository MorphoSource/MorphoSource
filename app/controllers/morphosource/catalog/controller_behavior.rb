module Morphosource
  module Catalog
    module ControllerBehavior

      def remove_hidden_children_display_facet
        byebug
      end

      def remove_hidden_child_facet_items
        # ids of media user is allowed to see
        safe_media_list = safe_list('child_media_ids_ssim')
        # return if safe list doesn't exist (admin)
        return if safe_media_list.nil?
        # child media ids returned by the search
        ids_facet = @response.aggregations["media_keyword_ids_ssim"]
        # return if no child media associated with objects
        return if ids_facet.nil?

        media_ids = ids_facet.items.map(&:value)
        # ids returned by the search that the user does not have access to
        hidden_ids = media_ids - safe_media_list
        byebug
        keyword_facet = @response.aggregations['media_keyword_sim']
        hidden_ids.each do |id|
          byebug
          # objects that have the media as a child
          objects = @document_list.select{ |object| object["child_media_ids_ssim"]&.include? id }

          # media solr document keywords that will need to be removed
          hidden_keywords = SolrDocument.find(id)["keyword_tesim"]

          objects.each do |object|
            # all the child media keywords
            object_media_keywords = object["media_keyword_tesim"]

            # for each keyword that needs to be hidden
            hidden_keywords.each do |keyword|
              # if the object has that keyword
              if object_media_keywords.include? keyword
                # delete it
                object_media_keywords.delete_at( object_media_keywords.index(keyword))
                # if the object no longer has that keyword
                if !object_media_keywords.include? keyword
                  # find the facet item
                  item = keyword_facet.items.find{|i| i.value == keyword}
                  # remove one of the hits or delete the item if there is only one hit left.

                  if item && item.hits == 1
                    keyword_facet.items.delete(item)
                  elsif item && item.hits > 1
                    item.hits -= 1
                  end
                end
              end
            end
          end
        end
      end

      def remove_hidden_facet_items
        access_controlled_facets.each do |facet|
          safe_list = safe_list(facet)
          next if safe_list.nil?
          facet = @response.aggregations[facet]
          next if facet.nil?
          values = facet.items.map(&:value)
          hidden_values = values - safe_list
          hidden_values.each do |value|
            item = facet.items.find{|i| i.value == value}
            facet.items.delete(item)
          end
        end
      end

      def safe_list(facet)
        facet = @response["responseHeader"]["params"]["f.#{facet}.facet.matches"]
      end

      # Keeping these here for now, may want to benchmark regex vs array

      # def remove_hidden_facet_items
      #   access_controlled_facets.each do |facet|
      #     safe_list = safe_list(facet)
      #     next if safe_list.nil?
      #     facet = @response.aggregations[facet]
      #     facet.items.each do |item|
      #       unless safe_list.match? item.value
      #         facet.items.delete(item)
      #       end
      #     end
      #   end
      # end

      # def safe_list(facet)
      #   facet = @response["responseHeader"]["params"]["f.#{facet}.facet.matches"]
      #   return unless facet
      #   Regexp.new(facet)
      # end

    end
  end
end
