# app/services/morphosource/three_d_use_types_service.rb
module Morphosource
  # Provide select options for the permits_3d_use field
  # Yes, this is somewhat ridiculously named, but Ruby class names
  # cannot start with a number.
  class ThreeDUseTypesService < Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('3d_use_types')
    end

    def include_current_value(value, _index, render_options, html_options)
      unless value.blank? || active?(value)
        html_options[:class] << ' force-select'
        render_options += [[label(value) { value }, value]]
      end
      [render_options, html_options]
    end

  end
end
