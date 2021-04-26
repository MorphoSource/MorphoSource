# Methods for populating the dashboard request manager page.
module Morphosource
  module Users
    module CartItems
      module ManageRequests

        # Items requested from user where status is 'requested'
        def new_requests
          @new_requests ||= newly_requested_items
        end

        # Requested items that have been cleared/approved/denied
        def previous_requests
          @previous_requests ||= previously_requested_items
        end

        # media works where user is reviewer
        #def reviewed_media_ids_NOT_USED
        #  @media ||= Morphosource::ReviewedMediaSearchService.call({ ms_id: ms_id }).map(&:id)
        #end
            #work_id: reviewed_media_ids,

        def newly_requested_items
          @new_requests ||= CartItem.where("array_to_string(reviewers, '||') ILIKE :id", id: ms_id).where(
            date_downloaded: nil, 
            date_approved: nil, 
            date_denied: nil, 
            date_canceled: nil, 
            date_expired: nil, 
            date_cleared: nil
          ).where('date_requested IS NOT NULL').order('user_id DESC').order('use desc')
        end

        def previously_requested_items
          @previous_requests ||= 
            CartItem.where("array_to_string(reviewers, '||') ILIKE :id", id: ms_id).where("date_approved IS NOT NULL OR date_cleared IS NOT NULL OR date_canceled IS NOT NULL OR date_denied IS NOT NULL OR date_expired < now()").order('user_id DESC').order('use desc')
        end

      end
    end
  end
end
