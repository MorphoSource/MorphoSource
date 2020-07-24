module Morphosource
  module Users
    module CartItems
      module MyDownloads

        def downloaded_items
          @downloads ||= cart_items.select(&:date_downloaded?)
        end

        def downloaded_item_ids
          downloaded_items.map(&:id)
        end

        def downloaded_work_ids
          downloaded_items.map(&:work_id)
        end
      end
    end
  end
end
