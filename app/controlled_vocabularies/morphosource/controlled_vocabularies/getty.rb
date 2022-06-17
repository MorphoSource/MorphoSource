module Morphosource
  module ControlledVocabularies
    module Getty

      # Return a tuple of url & label
      def solrize
        return [rdf_subject.to_s] if label.blank? || label == rdf_subject.to_s
        [rdf_subject.to_s, { label: "#{label}$#{rdf_subject}" }]
      end

      def label_english
        fetch.rdf_label.select{|l| l.language == :en}.first || rdf_subject.to_s
      end
      alias label label_english

    end
  end
end
