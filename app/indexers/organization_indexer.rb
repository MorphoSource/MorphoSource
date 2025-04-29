# Generated via
#  `rails generate hyrax:work Organization`
class OrganizationIndexer < Morphosource::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['date_managed_dtsi'] = object.date_managed
      solr_doc['continent_ssim'] = object.continent # some countries have multiple continents
    end
  end
end
