module Hyrax
  module Renderers
    class ShowcaseMorphosourceUseAgreementTypeAttributeRenderer < ShowcaseDefaultAttributeRenderer
      def attribute_value_to_html(value)
        Morphosource::MorphosourceUseAgreementTypesService.new.label(value)
      end
    end
  end
end