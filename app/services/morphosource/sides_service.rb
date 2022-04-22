# app/services/morphosource/sides_service.rb
module Morphosource
  # Provide select options for the sides field
  class SidesService < Hyrax::QaSelectService
    def initialize(_authority_name = nil)
      super('sides')
    end

    def active?(id)
      if authority.find(id).key?('active')
        authority.find(id).fetch('active')
      else
        return false
      end
    end

    def include_current_value(value, _index, render_options, html_options)
byebug
      value = value.capitalize
      unless value.blank? || active?(value)
        html_options[:class] << ' force-select'
        render_options += [[label(value) { value }, value]]
      end
      [render_options, html_options]
    end

    def OLD_include_current_value(value, _index, render_options, html_options)
      unless value.blank? || active?(value)
        html_options[:class] << ' force-select'
        render_options += [[label(value) { value }, value]]
      end
      [render_options, html_options]
    end

  end
end
