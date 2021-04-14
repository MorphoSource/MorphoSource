module Morphosource
  class PublicationBadge
      include ActionView::Helpers::TagHelper

      PUBLICATION_LABEL_CLASS = {
        open: "label-success",
        restricted: "label-info",
        preview: "label-info",
        hidden: "label-info",
        private: "label-danger",
        embargo: "label-warning",
        lease: "label-warning"
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
        "preview": "No Download",
        "hidden": "Hidden",
        "private": "Private",
        "embargo": "Embargo",
        "lease": "Lease"
      }

      def initialize(status)
        @status = status.to_sym
      end

      def render
        #content_tag(:span, text, class: "label #{dom_label_class}", style: "#{dom_label_style}")
        content_tag(:span, text, class: "label #{dom_label_class}")
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
