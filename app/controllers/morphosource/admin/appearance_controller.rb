module Morphosource
  module Admin
    class AppearanceController < ApplicationController
      include Morphosource::Admin::AdminBehavior

      def show
        add_breadcrumbs
        @form = form_class.new
      end

      def update
        form_class.new(update_params).update!
        redirect_to({ action: :show }, notice: update_notice)
      end

      private

      def form_params
        form_class::SETTINGS
      end

      def add_breadcrumbs
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.configuration'), '#'
      end

      def update_notice
        model_name = form_class.model_name.human.downcase
        "Sitewide #{model_name} updated successfully."
      end
    end
  end
end