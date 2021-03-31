module Morphosource
  module Users
    module CartItems
      module MyDownloads

        def downloaded_items(param_page=1, param_rows=10)
          @downloads ||= cart_items.where(
            date_downloaded: 100.year.ago..DateTime.current
          ).order('date_downloaded DESC').page(param_page).per(param_rows)
        end

#        def downloaded_items
#          @downloads ||= cart_items.select(&:date_downloaded?)
#        end
#
#        def downloaded_item_ids
#          downloaded_items.map(&:id)
#        end
#
#        def downloaded_work_ids
#          downloaded_items.map(&:work_id)
#        end
      end
    end
  end
end
