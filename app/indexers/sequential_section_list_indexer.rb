class SequentialSectionListIndexer < MediaListIndexer

  # @yield [Hash] calls the yielded block with the solr document
  # @return [Hash] the solr document WITH all changes
  def generate_solr_document
    super.tap do |solr_doc|
      specimen_doc = object&.specimen_doc.to_h
      solr_doc['physical_object_type_ssim'] = specimen_doc["human_readable_type_tesim"]
      solr_doc['physical_object_id_ssi'] = specimen_doc['id']
      solr_doc['record_source_ssim'] = specimen_doc['record_source_ssim']
      solr_doc['organization_id_ssim'] = specimen_doc['organization_id_ssim']
      solr_doc['taxonomy_id_ssim'] = specimen_doc['taxonomy_id_ssim']
      solr_doc['taxonomy_ssim'] = specimen_doc['taxonomy_ssim']
      solr_doc['gbif_taxonomy_id_ssim'] = specimen_doc['gbif_taxonomy_id_ssim']
      solr_doc['idigbio_uuid_tesim'] = specimen_doc['idigbio_uuid_tesim']
      solr_doc['occurrence_id_tesim'] = specimen_doc['occurrence_id_tesim']
    end
  end
end