module Morphosource
  module Admin
    module Appearance
      class BannersController < Morphosource::Admin::AppearanceController

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
          super
          add_breadcrumb "Banner", request.path
        end
      end
    end
  end
end