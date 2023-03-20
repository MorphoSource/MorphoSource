module Morphosource
  module My
    class PreviousRequestsController < RequestManagersController

      before_action :get_expiration_date_for_edit, only: [:edit_expiration]

      def edit_expiration
        mark_as('expired', value: @date)
        flash[:notice] = get_flash('expiration')
        redirect_to main_app.previous_requests_path
      end

    end
  end
end