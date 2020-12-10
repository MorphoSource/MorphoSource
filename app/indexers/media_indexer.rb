# Generated via
#  `rails generate hyrax:work Media`
class MediaIndexer < Morphosource::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  self.thumbnail_path_service = Morphosource::MediaThumbnailPathService

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['file_set_visibilities_ssim'] = object.file_set_visibilities
      solr_doc['fileset_accessibility_ssim'] = object.fileset_accessibility
      solr_doc['download_access_group_ssim'] = object.download_groups
      solr_doc['download_access_person_ssim'] = object.download_users
      solr_doc['owner_ssim'] = object.owner
      solr_doc['download_reviewer_ssim'] = object.download_reviewer
      # add media type facet
      solr_doc['human_readable_media_type_tesim'] = object.human_readable_media_type
      solr_doc['human_readable_media_type_sim'] = object.human_readable_media_type
      # add modality facet
      solr_doc['media_modality_tesim'] = object.modality
      solr_doc['media_modality_sim'] = object.modality
      # add physical object facet
      solr_doc['media_physical_object_type_tesim'] = object.physical_object_type
      solr_doc['media_physical_object_type_sim'] = object.physical_object_type
      # add organization facet
      solr_doc['media_organization_tesim'] = object.organization_titles
      solr_doc['media_organization_sim'] = object.organization_titles
      solr_doc['media_organization_id_ssim'] = object.organization_id
      # add public collection membership facet
      solr_doc['member_of_public_collection_ids_ssim'] = object.member_of_public_collection_ids
      # add taxonomies
      solr_doc['taxonomy_tesim'] = object.taxonomies_titles
      solr_doc['taxonomy_ssim'] = object.taxonomies_titles
      # related media ids
      solr_doc['related_media_ids_ssim'] = object.related_media_ids
      # physical_object_ids
      solr_doc['physical_object_id_ssim'] = object.physical_object_id
      solr_doc['physical_object_id_tesim'] = object.physical_object_id
   end
  end
end
