module Hyrax
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    with_themed_layout 'morphosource_dashboard'

    def show
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    end
  end
end
