module Hyrax
  module Renderers
    class ShowcaseUnitAttributeRenderer < ShowcaseDefaultAttributeRenderer
      def attribute_value_to_html(value)
        Morphosource::UnitsService.new.label(value)
      end
    end
  end
end