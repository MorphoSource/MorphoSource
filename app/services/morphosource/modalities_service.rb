# app/services/morphosource/modalities_service.rb
module Morphosource
  # Provide select options for the modalities field
  class ModalitiesService < QaSelectService
    FIELD_PREFIX_OVERRIDES = {
      'MicroNanoXRayComputedTomography' => 'ct',
      'Photogrammetry' => 'photogrammetry',
      'Photography' => 'photography'
    }.freeze

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

    # @return [Hash{String=>Hash}] lookup keyed by modality id for JS consumers
    def self.client_lookup
      service = new
      service.authority.all.each_with_object({}) do |entry, lookup|
        id = entry[:id] || entry['id']
        next if id.blank?

        lookup[id] = {
          term: label(id),
          abbreviation: abbreviation(id)
        }
      end
    end

    # Return the batch manifest field prefix for a modality id.
    # Most values use the authority abbreviation; a few are historical exceptions.
    #
    # @param id [String]
    # @return [String]
    def self.field_prefix(id)
      return 'Etc' if id.blank?

      FIELD_PREFIX_OVERRIDES.fetch(id) { abbreviation(id) }
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
