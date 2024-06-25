class UpdatePermissionTemplateSourceType < ActiveRecord::Migration[5.2]
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

  def up
    collection_ids = ActiveFedora::SolrService.query("collection_type_gid_ssim:*", rows: 999999, fl: 'id').map{ |coll| coll['id'] }

    collection_ids.each do |id|
      collection = Collection.find(id)
      template = collection.permission_template
      template.source_type = collection.collection_type.machine_id
      template.save
    rescue
    end

  end

  def down
    collection_ids = ActiveFedora::SolrService.query("collection_type_gid_ssim:*", rows: 999999, fl: 'id').map{ |coll| coll['id'] }

    collection_ids.each do |id|
      collection = Collection.find(id)
      template = collection.permission_template
      template.source_type = nil
      template.save
    rescue
    end
  end
end
