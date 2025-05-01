module Morphosource
  module Admin
    class ModalsController < ApplicationController
      include Morphosource::Admin::AdminBehavior

      def show
        add_breadcrumbs
        @form = form_class.new
      end

      def update
        form_class.new(update_params).update!
        # redirect_to({ action: :show }, notice: t('.flash.success'))
        redirect_to({ action: :show }, notice: "Sitewide modal updated successfully.")
      end

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

        def form_params
          form_class::MODAL_SETTINGS
        end

        def form_class
          Morphosource::Forms::Admin::Modal
        end

        def add_breadcrumbs
          add_breadcrumb t(:'hyrax.controls.home'), root_path
          add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
          add_breadcrumb t(:'hyrax.admin.sidebar.configuration'), '#'
          add_breadcrumb "Modal", request.path
        end

    end
  end
end
