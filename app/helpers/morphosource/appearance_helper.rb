# helper methods for sitewide modals and banners
module Morphosource
  module AppearanceHelper
      include ActionView::Helpers::UrlHelper

      def sitewide_banner?
        ActiveModel::Type::Boolean.new.cast(Morphosource::Forms::Admin::Banner.new.sitewide_banner)
      end

      def sitewide_banner_text
        Morphosource::Forms::Admin::Banner.new.sitewide_banner_text&.body&.to_html
      end

      # returns true if the sitewide modal should be shown
      # first check that the user has not temporarily opted out of seeing the modal
      # then check how often the modal should be shown
      def sitewide_modal?
        return false if cookies[:hide_donation_modal]

        modal_form = Morphosource::Forms::Admin::Modal.new
        # returns true if a random float is less than the frequency setting
        lucky_day?(modal_form)
      end

      # returns true if the sitewide modal should be shown
      def download_modal?
        # uncomment the line below to enable download modal snooze functionality
        # return false if cookies[:hide_download_modal]

        modal_form = Morphosource::Forms::Admin::Modals::DownloadModal.new
        # returns true if a random float is less than the frequency setting
        lucky_day?(modal_form)
      end

      def modal_body(modal)
        modal.modal_body&.body&.to_html
      end

      def guilt_trip_body(modal)
        modal.guilt_trip_body&.body&.to_html
      end

      private

      # returns true if the modal should be shown based on the frequency setting
      # uses a random number generator to determine if the modal should be shown
      # the frequency is a float between 0 and 1, where 1 means always show the modal
      def lucky_day?(modal_form)
        rand < modal_form.sitewide_modal_frequency.to_f
      end

  end
end