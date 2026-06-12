module Morphosource
  module Catalog
    class ObjectsByOccurrenceIdSearchBuilder < ObjectsCatalogSearchBuilder
      attr_reader :occurrence_id

      self.default_processor_chain += [:filter_by_occurrence_id]

      def initialize(scope:, occurrence_id:)
        @occurrence_id = occurrence_id
        super(scope)
      end

      def filter_by_occurrence_id(solr_parameters)
        solr_parameters[:fq] ||= []
        solr_parameters[:fq] << "occurrence_id_ssim:\"#{occurrence_id.gsub('"', '\\"')}\""
      end
    end
  end
end
