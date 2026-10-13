module Morphosource
  module Admin
    module Appearance
      class ModalsController < Morphosource::Admin::AppearanceController

        helper Morphosource::AppearanceHelper

        private

        def update_params
          params.require(:admin_modal).permit(form_params)
        end

        def form_class
          Morphosource::Forms::Admin::Modal
        end

        def add_breadcrumbs
          super
          add_breadcrumb "Modals", request.path
        end
      end
    end
  end
end
