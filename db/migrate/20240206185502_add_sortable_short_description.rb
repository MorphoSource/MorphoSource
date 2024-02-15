class AddSortableShortDescription < ActiveRecord::Migration[5.2]
  def up
    cho_media_docs = ActiveFedora::SolrService.query("media_physical_object_type_ssim:Cultural\\ Heritage\\ Object", rows: 999_999)

    cho_media_docs.each do |doc|
      short_description_ssi = doc['short_description_tesim']&.first&.downcase

      ActiveFedora::SolrService.add( { 'id' => doc['id'],
                                       'short_description_ssi': { 'set'  => short_description_ssi }
                                      }, softCommit: true )
    end
  end

  def down
    cho_media_docs = ActiveFedora::SolrService.query("media_physical_object_type_ssim:Cultural\\ Heritage\\ Object", rows: 999_999)

    cho_media_docs.each do |doc|
      ActiveFedora::SolrService.add( { 'id': doc['id'],
                                        'short_description_ssi': { 'set' => nil }
                                      }, softCommit: true )
    end
  end
end
