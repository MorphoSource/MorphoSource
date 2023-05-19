module Morphosource
  # Module to define core (non-modality specific) metadata properties for
  # media works
  module MediaMetadata
    extend ActiveSupport::Concern

    included do
      # -- Core metadata --

      property :remote_manifest_url, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/remoteManifestUrl"), multiple: false do |index|
        index.as :stored_searchable
      end

      property :remote_origin_url, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/remoteOriginUrl"), multiple: false do |index|
        index.as :stored_searchable
      end

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

      # -- Media-specific permissions metadata --

      # Funding Attribution
      property :funding, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/fundingAttribution") do |index|
        index.as :stored_searchable
      end

      # Publisher
      # Included in Basic Metadata
      # property :publisher, predicate: ::RDF::Vocab::DC11.publisher

      # Cite As
      property :cite_as, predicate: ::RDF::URI.new("http://ns.adobe.com/photoshop/1.0/Credit") do |index|
        index.as :stored_searchable
      end

      # -- Data Manager Status and Transfer Timing --
      # -- This is technical metadata and will be used by the repository ---

      # Should media management be transferred to the object organization when media is published?
      property :organization_transfer_on_publish, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/organizationTransferOnPublish"), multiple: false do |index|
        index.as :stored_sortable
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
    end
  end
end
