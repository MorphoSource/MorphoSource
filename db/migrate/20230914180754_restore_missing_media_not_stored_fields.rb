class RestoreMissingMediaNotStoredFields < ActiveRecord::Migration[5.2]
  def up
    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999)

    media_docs.each do |doc|
      admin_set_sim = doc['admin_set_tesim']
      creator_sim = doc['creator_tesim']
      generic_type_sim = doc['Work']
      human_readable_media_type_si = doc['human_readable_media_type_tesim']&.first
      human_readable_type_sim  = doc['human_readable_type_tesim']
      keyword_sim = doc['keyword_tesim']
      media_type_sim = doc['media_type_tesim']
      part_si = doc['part_tesim']&.first
      physical_object_title_si = doc['physical_object_title_tesim']&.first
      publication_satus_si = publication_status(doc)
      publisher_sim = doc['publisher_tesim']
      taxonomy_si = doc['taxonomy_tesim']
      unit_sim = doc['unit_tesim']

      ActiveFedora::SolrService.add( { 'id' => doc['id'],
                                       'admin_set_sim': { 'set'  => admin_set_sim },
                                       'creator_sim': { 'set' => creator_sim },
                                       'generic_type_sim': { 'set' => generic_type_sim },
                                       'human_readable_media_type_si': { 'set' => human_readable_media_type_si },
                                       'human_readable_type_sim': { 'set' => human_readable_type_sim },
                                       'keyword_sim': { 'set' => keyword_sim },
                                       'media_type_sim': { 'set' => media_type_sim },
                                       'part_si': { 'set' => part_si },
                                       'physical_object_title_si': { 'set' => physical_object_title_si },
                                       'publication_status_si': { 'set' => publication_status_si },
                                       'publisher_sim': { 'set' => publisher_sim },
                                       'taxonomy_si': { 'set' => taxonomy_si },
                                       'unit_sim': { 'set' => unit_sim }
                                      }, softCommit: true )
  end

  def down
    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999)

    media_docs.each do |doc|
      ActiveFedora::SolrService.add( { 'id': doc['id'],
                                        'admin_set_sim': { 'set' : nil },
                                        'creator_sim': { 'set': nil },
                                        'generic_type_sim': { 'set': nil },
                                        'human_readable_media_type_si': { 'set': nil },
                                        'human_readable_type_sim': { 'set': nil },
                                        'keyword_sim': { 'set': nil },
                                        'media_type_sim': { 'set': nil },
                                        'part_si': { 'set': nil },
                                        'physical_object_title_si': { 'set': nil },
                                        'publication_status_si': { 'set': nil },
                                        'publisher_sim': { 'set': nil },
                                        'taxonomy_si': { 'set': nil },
                                        'unit_sim': { 'set': nil }
                                        }, softCommit: true )
    end
  end

  def publication_status(doc)
    fa = doc['fileset_accessibility_ssim']
    if fa == ["open"]
      "Open Download"
    elsif fa == ["private"]
      "Private"
    elsif fa == ["restricted_download"]
      "Restricted Download"
    end
  end
end
