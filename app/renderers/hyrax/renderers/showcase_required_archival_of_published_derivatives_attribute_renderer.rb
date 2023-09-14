module Hyrax
  module Renderers
    class ShowcaseRequiredArchivalOfPublishedDerivativesAttributeRenderer < ShowcaseDefaultAttributeRenderer
      def attribute_value_to_html(value)
        Morphosource::RequiredArchivalOfPublishedDerivativesTypesService.new.label(value)
      end
    end
  end
end