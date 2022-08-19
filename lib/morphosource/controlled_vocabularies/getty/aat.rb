module Morphosource
  module ControlledVocabularies
    module Getty
      class Aat < ActiveTriples::Resource
        include Morphosource::ControlledVocabularies::GettyAuthorities

        class_attribute :label

        def cache_key_prefix
          'morphosource_getty_aat_label-v1-'
        end

        def service_name
          'aat'
        end

        self.label = lambda do |id, item|
          return if item[:status] == :error

          getty_preferred_term(item, id)
        end

        def self.getty_preferred_term(item, id)
          item[:data][getty_preferred_term_uri(item, id)]["http://vocab.getty.edu/ontology#term"]&.first["value"]
        end

        def self.getty_preferred_term_uri(item, id)
          item[:data][id]["http://vocab.getty.edu/ontology#prefLabelGVP"]&.first["value"]
        end

    end
  end
end
end
