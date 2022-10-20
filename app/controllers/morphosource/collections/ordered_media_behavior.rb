module Morphosource
  module Collections
    module OrderedMediaBehavior

      # PUT /media_lists/:id/order_media
      def order_media
        authorize! :edit, @collection
        begin
          @collection.ordered_media = ordered_media_ids
          @collection.save!
          flash[:notice] = 'Media order saved'
          flash.keep(:notice)
        rescue
          flash[:warning] = 'Error saving media order'
          flash.keep(:warning)
        end
        render :js => "window.location = '#{helpers.collection_media_path(@collection)}'"
      end

      def ordered_media_ids
        # Get all the collection media ids with sorting
        collection_media_ids = get_collection_media_ids
        # Media ids for current page, may have been reordered with drag and drop
        current_page_media_ids = params[:document]
        # Find indices of collection_media_ids that correspond to media in current page
        # Replace those indices of collection_media_ids with current_page_media_ids
        sub_current_page_id_order(collection_media_ids, current_page_media_ids)
      end

      # List of all ids in the collection, sorted if specified, otherwise params["sort"] default is by id asc.
      # Returns array of ids
      def get_collection_media_ids
        sort = params["sort"].split(',').join(' ')
        search_builder = self.search_builder_class.new(scope: self, collection: @collection).merge(fl: 'id', sort: sort).with( { rows: 999999 } )
        repository.search(search_builder).response["docs"].map{|d| d["id"]}
      end

      # Find indices of collection_media_ids that correspond to media in current page
      # Replace those indices of collection_media_ids with current_page_media_ids
      def sub_current_page_id_order(collection_ids, page_ids)
        index_range = current_page_media_indices
        x = 0
        index_range.each do |i|
          collection_ids[i] = page_ids[x]
          x += 1
        end
        [collection_ids.join(",")]
      end

      # Calculate indices of current page media ids relative to ids of the entire collection
      def current_page_media_indices
        page = params["page"].to_i
        page_count = params["per_page"].to_i
        low_index = (page - 1) * page_count
        high_index = (page * page_count - 1)
        Array((low_index..high_index))
      end

      # called from media list controller if @collection.ordered_media is present
      # adds position to each of the media docs
      def sort_document_list(document_list)
        page = params["page"].present? ? params["page"].to_i : 1
        per = params["per_page"].present? ? params["per_page"].to_i : @blacklight_config.default_solr_params[:rows]

        @collection.ordered_media.first.split(",").each_with_index do |id, index|
          doc = document_list.find {|x| x['id'] == id }
          if doc.nil?
            next
          else
            # Blacklight::Document#[]= is deprecated; using obj.to_h.[]= instead.
            new_doc = doc.dup.to_h
            new_doc["position"] = index + 1
            document_list[document_list.index(doc)] = SolrDocument.new(new_doc)
          end
        end
        # if the user is sorting by a column value, use that. Otherwise, sort on position.
        unless params["sort"].present?
          document_list.sort_by! { |doc| doc["position"] || 999999 }
        end

        # Paginate document list
        Kaminari.paginate_array(document_list, total_count: document_list.count).page(page).per(per)
      end

    end
  end
end