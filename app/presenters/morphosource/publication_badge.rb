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

      PUBLICATION_LABEL_STYLE = {
        open: "",
        restricted: "border-color: red;",
        preview: "",
        hidden: "border-color: black;",
        private: "",
        embargo: "background-color: black;",
        lease: "background-color: black;"
      }

      def initialize(status)
        @status = status
      end

      def render
        content_tag(:span, text, class: "label #{dom_label_class}", style: "#{dom_label_style}")
      end

      private

        def dom_label_class
          PUBLICATION_LABEL_CLASS.fetch(@status.to_sym)
        end

        def dom_label_style
          PUBLICATION_LABEL_STYLE.fetch(@status.to_sym)
        end

        def text
          I18n.t("morphosource.publication_status.#{@status}.text")
        end
    
  end
end
