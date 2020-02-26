
module Hyrax
  module Renderers
    class ShowcaseDateAttributeRenderer < ShowcaseDefaultAttributeRenderer

	    def attribute_value_to_html(value)
	      display_date(value) # use the method from morphosource helper
	    end
    end
  end
end