module Morphosource
  module ControlledVocabularies
    module Getty
      class Tgn < ActiveTriples::Resource
        include  Morphosource::ControlledVocabularies::GettyAuthorities

        class_attribute :label

        def cache_key_prefix
          'morphosource_getty_tgn_label-v1-'
        end

        def service_name
          'tgn'
        end

        self.label = lambda do |item|
          return if item[:status] == :error

          preferred_term = getty_preferred_term_uri(item)

          begin
            response = RestClient.get(preferred_term + '.json')
            body = JSON.parse(response.body)
            body[preferred_term]["http://vocab.getty.edu/ontology#term"].first["value"]
          rescue
            return
          end
        end

        def self.getty_preferred_term_uri(item)
          bindings = item[:data]["results"]["bindings"]
          bindings.select{ |triple| triple["Predicate"]["value"] == "http://vocab.getty.edu/ontology#prefLabelGVP"}&.first["Object"]["value"]
        end

    end
  end
end
end
