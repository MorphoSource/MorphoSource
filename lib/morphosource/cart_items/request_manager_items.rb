module Morphosource
  module CartItems
    module RequestManagerItems

      def get_requesters(tab)
        case tab
        when 'new'
          @requesters = get_new_requesters
        when 'previous'
          @requesters = get_previous_requesters
        end
      end

      def get_new_requesters
        ids = new_requests_user_ids
        User.where(ms_id: ids).page params[:page]
      end

      def get_previous_requesters
        ids = previous_requests_user_ids
        User.where(ms_id: ids).page params[:page]
      end

      def new_requests_user_ids
        new_requests.map(&:user_id)
      end

      def previous_requests_user_ids
        previous_requests.map(&:user_id)
      end

      delegate :new_requests, :previous_requests, to: :current_user
    end
  end
end
