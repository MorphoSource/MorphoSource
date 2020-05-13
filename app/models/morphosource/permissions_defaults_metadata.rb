module Morphosource
  module PermissionsDefaultsMetadata
    extend ActiveSupport::Concern

    # When an organization has a linked team, the team manager can set the following fields on the organization, which determine the default setting for any media created from the organization's physical objects.

    # Publication Status
    # Download Reviewer
    # License
    # Copyright Statement
    # Custom Terms of Use
    # Additional Usage Agreement
    # Commercial Use Permitted
    # 3D Use Permitted
    # IP Holder
    # Funding Attribution
    # Publisher
    # Cite As

    included do
      # Publication Status set on Organization
      # Determines default publication settings
      # media visibility, fileset_visibility, fileset_accessibility

      # Download Reviewer
      property :download_reviewer, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/downloadReviewer"), multiple: true do |index|
        index.as :stored_searchable
      end

      # Copyright License
      property :agreement_uri, predicate: ::RDF::URI.new("http://ns.adobe.com/xap/1.0/rights/UsageTerms") do |index|
        index.as :stored_searchable
      end

      # License
      # Included in Basic Metadata
      # property :license, predicate: ::RDF::Vocab::DC.license, multiple: true

      # Copyright Statement
      # Included in Basic Metadata
      # property :rights_statement, predicate: ::RDF::Vocab::EDM.rights

      # Custom Terms of Use
      property :terms_of_use, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/termsOfUse") do |index|
        index.as :stored_searchable
      end

      # Commercial Use Permitted
      property :permits_commercial_use, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/permitsCommercialUse") do |index|
        index.as :stored_searchable
      end

      # 3D Use Permitted
      property :permits_3d_use, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/permits3dUse") do |index|
        index.as :stored_searchable
      end

      # Rights Holder
      property :rights_holder, predicate: ::RDF::URI.new("http://ns.adobe.com/xap/1.0/rights/Owner") do |index|
        index.as :stored_searchable
      end

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
    end
  end
end
