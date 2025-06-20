module Morphosource
  module Admin
    module AdminBehavior
      extend ActiveSupport::Concern

      included do
        before_action :require_admin
        with_themed_layout 'morphosource_dashboard'
      end

      def require_admin
        authorize! :read, :admin_dashboard
      end
    end
  end
end