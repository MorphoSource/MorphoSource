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
     solr_doc['fileset_accessibility_ssim'] = object.fileset_accessibility
     solr_doc['download_access_group_ssim'] = object.download_groups
     solr_doc['download_access_person_ssim'] = object.download_users
     solr_doc['owner_ssim'] = object.owner
     object.download_reviewer
     solr_doc['download_reviewer_ssim'] = object.download_reviewer
   end
  end
end
