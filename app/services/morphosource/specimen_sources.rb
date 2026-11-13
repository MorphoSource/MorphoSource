module Morphosource
  # Remote sources specimen metadata is imported from, in Hyrax.config.specimen_record_sources order.
  module SpecimenSources
    # Raised by a source when its API returns an error or times out
    class SourceError < StandardError; end

    SOURCES = {
      gbif: 'Morphosource::SpecimenSources::GbifSource',
      idigbio: 'Morphosource::SpecimenSources::IDigBioSource'
    }.freeze

    def self.configured
      Hyrax.config.specimen_record_sources.map { |key| self.for(key) }
    end

    def self.for(key)
      SOURCES.fetch(key.to_sym).constantize.new
    end
  end
end
