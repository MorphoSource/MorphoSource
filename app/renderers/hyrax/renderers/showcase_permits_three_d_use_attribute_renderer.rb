module Hyrax
  module Renderers
    class ShowcasePermitsThreeDUseAttributeRenderer < ShowcaseDefaultAttributeRenderer
      def attribute_value_to_html(value)
        Morphosource::ThreeDUseTypesService.new.label(value)
      end
    end
  end
end