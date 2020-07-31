# Methods for populating the dashboard request manager page.
module Morphosource
  module Users
    module CartItems
      module ManageRequests

        # Items requested from user (items where user is data manager)
        def requests
          @requests ||= requested_items
        end

        # Items requested from user where status is 'requested'
        def new_requests
          @new_requests ||= newly_requested_items
        end

        # Requested items that have been cleared/approved/denied
        def previous_requests
          @previous_requests ||= previously_requested_items
        end

        # From media work solr docs where user ms_id is in the owner, depositor, or download reviewer field, select the ones where the user is the reviewer.
        # reviewer = download_reviewer || owner || depositor
        # Find all CartItems corresponding to those media and select only the ones that have been requested or cleared (will not return items that have been added to a user's cart but have not been requested)
        def requested_items
          items = CartItem.where(work_id: reviewed_media_ids)
          items.select{ |i| i.date_requested? || i.date_cleared? }
        end

        # media works where user is reviewer
        def reviewed_media_ids
          @media ||= Morphosource::ReviewedMediaSearchService.call({ ms_id: ms_id }).map(&:id)
        end

        def newly_requested_items
          requests.select{ |item| item.request_status == "Requested" }
        end

        def previously_requested_items
          requests - new_requests
        end

        def previously_requested_item_ids
          previous_requests.map(&:id)
        end

        def requested_item_ids
          requests.map(&:id)
        end

        def requested_items_work_ids
          requests.map(&:work_id)
        end

        def newly_requested_item_ids
          new_requests.map(&:id)
        end

        def newly_requested_item_work_ids
          new_requests.map(&:work_id)
        end

        def newly_requested_items_user_ids
          new_requests.map(&:user_id)
        end

        def previously_requested_item_ids
          previous_requests.map(&:id)
        end

        def previously_requested_items_work_ids
          previous_requests.map(&:work_id)
        end

        def previously_requested_items_user_ids
          previous_requests.map(&:user_id)
        end
      end
    end
  end
end
