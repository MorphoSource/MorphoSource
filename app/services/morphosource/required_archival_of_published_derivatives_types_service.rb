# app/services/morphosource/required_archival_of_published_derivatives_types_service.rb
module Morphosource
  # Provide select options for the series types field
  class RequiredArchivalOfPublishedDerivativesTypesService < QaSelectService
    def initialize(_authority_name = nil)
      super('required_archival_of_published_derivatives_types')
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
