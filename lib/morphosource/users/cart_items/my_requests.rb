# Methods for populating the dashboard requests page
module Morphosource
  module Users
    module CartItems
      module MyRequests

        def my_requests(param_page=1, param_rows=10)
          @my_requests ||= cart_items.where(
            "date_requested IS NOT NULL OR date_cleared IS NOT NULL"
            ).order('created_at DESC').page(param_page).per(param_rows)
        end

        def my_active_requests
          # this method is called in the Media page.  Might need to be optimized 
          @my_active_requests ||= my_requests.select{ |item| ["Approved","Requested","Cleared"].include? item.request_status }
        end

        def my_approved_requests
          @my_approved_requests ||= cart_items.where(
            date_canceled: nil, 
            date_denied: nil, 
            date_expired: DateTime.current.to_date..100.years.from_now.to_date, 
            date_approved: 100.year.ago..DateTime.current
          )
        end

        def my_approved_requests_work_ids
          my_approved_requests.map(&:work_id)
        end

        def my_active_requests_work_ids
          my_active_requests.map(&:work_id)
        end

        def my_cleared_requests
          my_requests.select{|item| item.request_status == "Cleared" }
        end

        def my_cleared_requests_work_ids
          my_cleared_requests.map(&:work_id)
        end

      end
    end
  end
end
