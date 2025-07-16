module Morphosource
  module Admin
    module Appearance
      module Modals
        class DownloadModalsController < Morphosource::Admin::Appearance::ModalsController


          private

          def snooze_cookie_key
            :hide_download_modal
          end

          def update_params
            params.require(:admin_download_modal).permit(form_params)
          end

          def form_class
            Morphosource::Forms::Admin::Modals::DownloadModal
          end

          def add_breadcrumbs
            super
            add_breadcrumb "Download Modals", request.path
          end
        end
      end
    end
  end
end
