# app/services/morphosource/modalities_service.rb
module Morphosource
  # Provide select options for the modalities field
  class ModalitiesService < QaSelectService
    # Return short abbreviation for modality term id
    #
    # @param id [String]
    # @return [String] abbreviation for modality id or "Etc" if not found
    def self.abbreviation(id)
      new.fetch(id, 'abbreviation') { "Etc" }
    end

    # @param id [String]
    # @return [String] label for modality or id value if not found
    def self.label(id)
      new.label(id) { id }
    end

    def initialize(_authority_name = nil)
      super('modalities')
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
