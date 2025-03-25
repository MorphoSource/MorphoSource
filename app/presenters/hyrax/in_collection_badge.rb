
module Hyrax
  class InCollectionBadge
    include ActionView::Helpers::TagHelper

    # @param is_voucher [String] the current is_voucher
    def initialize(is_voucher)
      @is_voucher = is_voucher
    end

    # Draws a span tag with styles for a bootstrap label
    def render
      content_tag(:span, text, class: "badge badge-primary", id: "in-collection-badge")
    end

    private

      def text
        if @is_voucher.present?
          if @is_voucher.first == 'Yes'
            'In Collection'
          else
            'Not in Collection'
          end
        else
          # should not be here since the field is set by a dropdown Yes / No
        end
      end

  end
end