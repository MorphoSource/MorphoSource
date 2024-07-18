module Hyrax
  module Renderers
    class ShowcaseMediaOwnershipTransferAttributeRenderer < ShowcaseDefaultAttributeRenderer

      private

      def attribute_value_to_html(value)
        case value
        when 'true'
          t('morphosource.renderers.showcase_media_ownership_transfer_attribute_renderer.enabled')
        else
          t('morphosource.renderers.showcase_media_ownership_transfer_attribute_renderer.not_enabled')
        end
      end

    end
  end
end