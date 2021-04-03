module Morphosource
  module Users
    module CartItems
      module MyDownloads

        def downloaded_items(param_page=1, param_rows=10)
          @downloads ||= cart_items.where(
            "date_downloaded IS NOT NULL"
            ).order('date_downloaded DESC').page(param_page).per(param_rows)
        end

      end
    end
  end
end
