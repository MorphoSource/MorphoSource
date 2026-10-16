module Morphosource
  module CartItems
    module RequestItems

      def get_intended_use
        if params[:intended_use].present?
          @intended_use = params[:intended_use].first
        else
          @intended_use = ''
        end
      end

      def check_request_terms_agree
        unless params[:request_download_terms_agreed] == "on"
          flash[:error] = "You must agree to all download agreements."
          redirect_back(fallback_location: my_requests_path)
        end
      end

      def create_new_requested_item(work_id)
        item = create_cart_item(work_id)
        make_request(item)
        return item
      end

      # Re-resolves reviewers synchronously: callers notify item.reviewers immediately afterwards.
      def make_request(items)
        items = Array(items)
        reviewers_by_work_id = Morphosource::DownloadReviewerResolver.new.reviewers_by_media_id(items.map(&:work_id).uniq)
        items.each do |item|
          attributes = { date_cleared: nil, date_requested: Time.now, use: @intended_use, download_request_terms_agreement: true }
          reviewers = reviewers_by_work_id[item.work_id]
          attributes[:reviewers] = reviewers unless reviewers.nil? || Array(item.reviewers).to_set == reviewers.to_set
          item.update(attributes)
        end
      end

      # @return [Array<CartItem>] the new requested items replacing the inactive ones
      def re_request(items)
        mark_as('in_cart',items,value: false)
        create_new_items(items)
      end

      def requested(items)
        items.select{|item| item.date_requested }
      end

      # For restricted items, returns those w/ request_status ("Not Requested", "Cleared")
      def unrequested(items)
        items.select{|item| !item.date_requested }
      end

      # For restricted items, returns those w/ request_status ("Expired","Denied","Canceled")
      def inactive(items)
        items.select{|item| item.inactive_request? }
      end

    end
  end
end
