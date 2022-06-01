module Morphosource
  module ControlledVocabularies
    module Getty
      class Tgn < ActiveTriples::Resource
        include Morphosource::ControlledVocabularies::Getty

        def label_english
          fetch.rdf_label.first
        end
        alias label label_english

      end
    end
  end
end
