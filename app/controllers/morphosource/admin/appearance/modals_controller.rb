module Morphosource
  module Admin
    module Appearance
      class ModalsController < Morphosource::Admin::AppearanceController

        helper Morphosource::AppearanceHelper

        before_action :require_admin, except: [:snooze_hour, :snooze_day, :snooze_week]

        def snooze_hour
          cookies[snooze_cookie_key] = { value: true, expires: 1.hour.from_now }
          head :ok
        end

        def snooze_day
          cookies[snooze_cookie_key] = { value: true, expires: 1.day.from_now }
          head :ok
        end

        def snooze_week
          cookies[snooze_cookie_key] = { value: true, expires: 1.week.from_now }
          head :ok
        end

        private

        def snooze_cookie_key
          :hide_donation_modal
        end

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
