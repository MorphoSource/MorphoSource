# Generated via
#  `rails generate hyrax:work Media`
class MediaIndexer < Morphosource::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  def generate_solr_document
   super.tap do |solr_doc|
     solr_doc['file_set_visibilities_ssim'] = object.file_set_visibilities
   end
  end
end
