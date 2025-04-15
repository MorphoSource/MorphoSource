module Morphosource
  class PublicationBadge
      include ActionView::Helpers::TagHelper

      PUBLICATION_LABEL_CLASS = {
        open: "badge-success",
        restricted: "badge-info",
        restricted_download: "badge-info",
        preview: "badge-info",
        preview_only: "badge-info",
        hidden: "badge-info",
        private: "badge-danger",
        embargo: "badge-warning",
        lease: "badge-warning"
      }

      #PUBLICATION_LABEL_STYLE = {
      #  open: "",
      #  restricted: "border-color: red;",
      #  preview: "",
      #  hidden: "border-color: black;",
      #  private: "",
      #  embargo: "background-color: black;",
      #  lease: "background-color: black;"
      #}

      PUBLICATION_LABEL_TEXT = {
        "open": "Open Download",
        "restricted": "Restricted Download",
        "restricted_download": "Restricted Download",
        "preview": "No Download",
        "preview_only": "No Download",
        "hidden": "Hidden",
        "private": "Private",
        "embargo": "Embargo",
        "lease": "Lease"
      }

      def initialize(status)
        @status = status.to_sym
      end

      def render
        content_tag(:span, text, class: "badge #{dom_label_class}")
      end

      private

        def dom_label_class
          PUBLICATION_LABEL_CLASS.fetch(@status)
        end

        def dom_label_style
          PUBLICATION_LABEL_STYLE.fetch(@status)
        end

        def text
          #I18n.t("morphosource.publication_status.#{@status}.text")
          PUBLICATION_LABEL_TEXT.fetch(@status)
        end

  end
end
