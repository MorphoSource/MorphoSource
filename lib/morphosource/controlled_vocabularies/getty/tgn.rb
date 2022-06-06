module Morphosource
  module ControlledVocabularies
    module Getty
      class Tgn < ActiveTriples::Resource
        include Morphosource::ControlledVocabularies::Getty

        # include ::Hyrax::ControlledVocabularies::ResourceLabelCaching

        def label_english
          fetch.rdf_label.first
        end
        alias label label_english

      end
    end
  end
end
