# Methods for populating the dashboard request manager page.
module Morphosource
  module Users
    module CartItems
      module ManageRequests

        # Items requested from user (items where user is data manager)
#        def requests_NOT_USED
#          @requests ||= requested_items
#        end

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
#        def requested_items_NOT_USED
#          items = CartItem.where(work_id: reviewed_media_ids)
#          items.select{ |i| i.date_requested? || i.date_cleared? }
#        end

        # media works where user is reviewer
        def reviewed_media_ids
          @media ||= Morphosource::ReviewedMediaSearchService.call({ ms_id: ms_id }).map(&:id)
        end

        def newly_requested_items
          @new_requests ||= CartItem.where(
            work_id: reviewed_media_ids,
            date_downloaded: nil, 
            date_requested: 100.year.ago..DateTime.current,
            date_approved: nil, 
            date_denied: nil, 
            date_canceled: nil, 
            date_expired: nil, 
            date_cleared: nil
          ).order('user_id DESC').order('use desc')
        end

#        def newly_requested_items_NOT_USED
#          requests.select{ |item| item.request_status == "Requested" }
#        end

        def previously_requested_items
          @previous_requests ||= 
            CartItem.where(work_id: reviewed_media_ids).where("date_approved IS NOT NULL OR date_cleared IS NOT NULL OR date_canceled IS NOT NULL OR date_denied IS NOT NULL OR date_expired < now()").order('user_id DESC').order('use desc')
        end

#        def previously_requested_items_NOT_USED
#          requests - new_requests
#        end

#        def previously_requested_item_ids
#          previous_requests.map(&:id)
#        end

#        def requested_item_ids_NOT_USED
#          requests.map(&:id)
#        end
#
#        def requested_items_work_ids_NOT_USED
#          requests.map(&:work_id)
#        end

#        def newly_requested_item_ids
#          new_requests.map(&:id)
#        end
#
#        def newly_requested_item_work_ids
#          new_requests.map(&:work_id)
#        end
#
#        def newly_requested_items_user_ids
#          new_requests.map(&:user_id)
#        end

#        def previously_requested_item_ids
#          previous_requests.map(&:id)
#        end
#
#        def previously_requested_items_work_ids
#          previous_requests.map(&:work_id)
#        end
#
#        def previously_requested_items_user_ids
#          previous_requests.map(&:user_id)
#        end
      end
    end
  end
end
