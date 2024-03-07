# app/services/morphosource/mime_types_service.rb
module Morphosource
  # Return label as need for MIME types defined in CV list
  class MimeTypesService < QaSelectService
    # @param id [String]
    # @return [String] label for mime type or id value if not found
    def self.label(id)
      new.label(id) { id }
    end

    def initialize(_authority_name = nil)
      super('mime_types')
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
