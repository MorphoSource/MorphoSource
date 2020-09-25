# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
class BiologicalSpecimenIndexer < Morphosource::PhysicalObjectIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
   super.tap do |solr_doc|
     # taxonomy
     solr_doc['taxonomy_tesim'] = object.taxonomies_titles
     solr_doc['taxonomy_ssim'] = object.taxonomies_titles
   end
  end
end
