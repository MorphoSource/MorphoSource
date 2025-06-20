module Morphosource
  module Admin
    module Appearance
      class ModalsController < Morphosource::Admin::AppearanceController

        def snooze_hour
          cookies[:hide_donation_modal] = { value: true, expires: 1.hour.from_now }
          head :ok
        end

        def snooze_day
          cookies[:hide_donation_modal] = { value: true, expires: 1.day.from_now }
          head :ok
        end

        def snooze_week
          cookies[:hide_donation_modal] = { value: true, expires: 1.week.from_now }
          head :ok
        end

        private

        def update_params
          params.require(:admin_modal).permit(form_params)
        end

        def form_class
          Morphosource::Forms::Admin::Modal
        end

        def add_breadcrumbs
          super
          add_breadcrumb "Modal", request.path
        end
      end
    end
  end
end
