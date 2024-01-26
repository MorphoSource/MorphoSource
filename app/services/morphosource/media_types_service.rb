# app/services/morphosource/media_types_service.rb
module Morphosource
  # Provide select options for the media types field
  class MediaTypesService < QaSelectService
    # Return short term for modality term id
    #
    # @param id [String]
    # @return [String] short term for media type id or id if not found
    def self.short_term(id)
      new.fetch(id, 'short') { id }
    end

    # @param id [String]
    # @return [String] label for media type or id value if not found
    def self.label(id)
      new.label(id) { id }
    end

    def initialize(_authority_name = nil)
      super('media_types')
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
