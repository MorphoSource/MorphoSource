class StoreUnstoredFields < ActiveRecord::Migration[5.2]
  def up
    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999)

    media_docs.each do |doc|
      admin_set_ssim = doc['admin_set_tesim']
      creator_ssim = doc['creator_tesim']
      generic_type_ssim = ['Work']
      human_readable_media_type_ssi = doc['human_readable_media_type_tesim']&.first
      human_readable_type_ssim  = doc['human_readable_type_tesim']
      keyword_ssim = doc['keyword_tesim']
      map_type_ssim = doc['map_type_tesim']
      media_type_ssim = doc['media_type_tesim']
      part_ssi = doc['part_tesim']&.first
      physical_object_title_ssi = doc['physical_object_title_tesim']&.first
      publication_status_ssi = publication_status(doc)
      publisher_ssim = doc['publisher_tesim']
      series_type_ssim = doc['series_type_tesim']
      short_description_ssim = doc['short_description_tesim']
      side_ssim = doc['side_tesim']
      taxonomy_ssi = doc['taxonomy_tesim']&.first
      unit_ssim = doc['unit_tesim']

      ActiveFedora::SolrService.add( { 'id' => doc['id'],
                                       'admin_set_ssim': { 'set'  => admin_set_ssim },
                                       'creator_ssim': { 'set' => creator_ssim },
                                       'generic_type_ssim': { 'set' => generic_type_ssim },
                                       'human_readable_media_type_ssi': { 'set' => human_readable_media_type_ssi },
                                       'human_readable_type_ssim': { 'set' => human_readable_type_ssim },
                                       'keyword_ssim': { 'set' => keyword_ssim },
                                       'map_type_ssim': { 'set' => map_type_ssim },
                                       'media_type_ssim': { 'set' => media_type_ssim },
                                       'part_ssi': { 'set' => part_ssi },
                                       'physical_object_title_ssi': { 'set' => physical_object_title_ssi },
                                       'publication_status_ssi': { 'set' => publication_status_ssi },
                                       'publisher_ssim': { 'set' => publisher_ssim },
                                       'series_type_ssim': { 'set' => series_type_ssim },
                                       'short_description_ssim': { 'set' => short_description_ssim },
                                       'side_ssim': { 'set' => side_ssim },
                                       'taxonomy_ssi': { 'set' => taxonomy_ssi },
                                       'unit_ssim': { 'set' => unit_ssim }
                                      }, softCommit: true )
    end
  end

  def down
    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999)

    media_docs.each do |doc|
      ActiveFedora::SolrService.add( { 'id': doc['id'],
                                        'admin_set_ssim': { 'set' => nil },
                                        'creator_ssim': { 'set'=> nil },
                                        'generic_type_ssim': { 'set'=> nil },
                                        'human_readable_media_type_ssi': { 'set'=> nil },
                                        'human_readable_type_ssim': { 'set'=> nil },
                                        'keyword_ssim': { 'set'=> nil },
                                        'map_type_ssim': { 'set' => nil },
                                        'media_type_ssim': { 'set'=> nil },
                                        'part_ssi': { 'set'=> nil },
                                        'physical_object_title_ssi': { 'set'=> nil },
                                        'publication_status_ssi': { 'set'=> nil },
                                        'publisher_ssim': { 'set'=> nil },
                                        'series_type_ssim': { 'set' => nil },
                                        'short_description_ssim': { 'set' => nil },
                                        'side_ssim': { 'set' => nil },
                                        'taxonomy_ssi': { 'set'=> nil },
                                        'unit_ssim': { 'set'=> nil }
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

