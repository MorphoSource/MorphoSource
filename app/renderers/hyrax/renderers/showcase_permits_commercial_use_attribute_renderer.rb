module Hyrax
  module Renderers
    class ShowcasePermitsCommercialUseAttributeRenderer < ShowcaseDefaultAttributeRenderer
      def attribute_value_to_html(value)
        Morphosource::CommercialUseTypesService.new.label(value)
      end
    end
  end
end