module Morphosource
  module Admin
    module Appearance
      class BannersController < ApplicationController
        include Morphosource::Admin::AdminBehavior

        def show
          add_breadcrumbs
          @form = form_class.new
          # @form.sitewide_banner_text = banner_text
        end

        def update
          form_class.new(update_params).update!
          redirect_to({ action: :show }, notice: "Sitewide banner updated successfully.")
        end

        private

        def update_params
          params.require(:admin_banner).permit(form_params)
        end

        def form_params
          form_class::SETTINGS + ["sitewide_banner_text"]
        end

        def form_class
          Morphosource::Forms::Admin::Banner
        end

        def add_breadcrumbs
          add_breadcrumb t(:'hyrax.controls.home'), root_path
          add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
          add_breadcrumb t(:'hyrax.admin.sidebar.configuration'), '#'
          add_breadcrumb "Banner", request.path
        end
      end
    end
  end
end