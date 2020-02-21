
module Hyrax
  module Renderers
    class ShowcaseDateAttributeRenderer < ShowcaseDefaultAttributeRenderer

      private

        def attribute_value_to_html(value)
          display_date(value) # use the method from morphosource helper
        end

    end
  end
end