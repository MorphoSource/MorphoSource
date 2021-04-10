module Morphosource
  # Module to define core (non-modality specific) metadata properties for
  # media works
  module MediaMetadata
    extend ActiveSupport::Concern

    included do
      # -- Core metadata --

      # Required select values
      property :media_type, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/subtypeLiteral") do |index|
        index.as :stored_searchable, :facetable
      end

      # Optional select values
      property :short_description, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/shortDescription") do |index|
        index.as :stored_searchable, :facetable
      end

      property :side, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/comments") do |index|
        index.as :stored_searchable, :facetable
      end

      property :series_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/seriesType") do |index|
        index.as :stored_searchable, :facetable
      end

      # Optional free text values
      property :part, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/subjectPart") do |index|
        index.as :stored_searchable
      end

      property :orientation, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/subjectOrientation") do |index|
        index.as :stored_searchable
      end

      property :media_status, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/mediaStatus") do |index|
        index.as :stored_searchable
      end

      # Fields not present on edit/show form
      property :legacy_media_file_id, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/providerManagedID") do |index|
        index.as :stored_searchable
      end

      property :legacy_media_group_id, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/IDofContainingCollection") do |index|
        index.as :stored_searchable
      end

      property :uuid, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/mediaUUID") do |index|
        index.as :stored_searchable
      end

      property :ark, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/mediaARK") do |index|
        index.as :stored_searchable
      end

      property :doi, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/mediaDOI") do |index|
        index.as :stored_searchable
      end

      property :available, predicate: ::RDF::Vocab::DC.available do |index|
        index.as :stored_searchable
      end

      # -- Management of File Visibility/Download/View --
      # -- Default settings can be set by organization linked team --

      # Stores user-selected default setting for file set visibility
      property :fileset_visibility, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/filesetVisibility") do |index|
        index.as :stored_searchable
      end

      # Stores user-selected setting for restricting download/viewing behavior
      property :fileset_accessibility, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/filesetAccessibility") do |index|
        index.as :stored_searchable
      end

      # -- Media type-specific metadata --

      # ImageSeries fields
      property :number_of_images_in_set, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/dicomNumberOfSeriesRelatedInstances"), multiple: false do |index|
        index.as :stored_searchable
      end

      # CTImageSeries fields
      property :x_spacing, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/dicomPixelSpacingWidth") do |index|
        index.as :stored_searchable
      end

      property :y_spacing, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/dicomPixelSpacingHeight") do |index|
        index.as :stored_searchable
      end

      property :z_spacing, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/dicomSpacingBetweenSlices") do |index|
        index.as :stored_searchable
      end

      property :slice_thickness, predicate: ::RDF::URI.new("http://purl.org/healthcarevocab/v1#SliceThickness") do |index|
        index.as :stored_searchable
      end

      # PhotogrammetryImageSeries fields
      property :scale_bar, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/scaleBar") do |index|
        index.as :stored_searchable
      end

      # Mesh and CTImageSeries field
      property :unit, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/ACExt/units") do |index|
        index.as :stored_searchable, :facetable
      end

      # Mesh field
      property :map_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/mapType") do |index|
        index.as :stored_searchable, :facetable
      end

      # anonymize_origin
      property :anonymize_origin, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/anonymizeOrigin") do |index|
        index.as :stored_searchable
      end
    end
  end
end
