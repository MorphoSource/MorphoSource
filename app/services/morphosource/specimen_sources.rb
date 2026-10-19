module Morphosource
  # Remote sources (e.g. iDigBio) that specimen metadata can be imported from.
  # Sources are tried in the order given by Hyrax.config.specimen_record_sources.
  module SpecimenSources
    # Raised by a source when its API returns an error or times out
    class SourceError < StandardError; end

    SOURCES = {
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
