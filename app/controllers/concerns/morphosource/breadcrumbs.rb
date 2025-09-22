module Morphosource
  module Breadcrumbs
    extend ActiveSupport::Concern
    include Hyrax::Breadcrumbs

    included do
      before_action :build_breadcrumbs, only: [:index]
    end

    def build_breadcrumbs
      add_dashboard_path
      add_breadcrumb_for_action
    end

    private

    def add_dashboard_path
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    end

    def add_breadcrumb_for_action
      add_breadcrumb self.class::PAGE_TITLE, request.path, mark_active_action
    end

    def mark_active_action
      { "aria-current" => "page" }
    end
  end
end
