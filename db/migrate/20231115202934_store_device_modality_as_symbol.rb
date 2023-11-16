class StoreDeviceModalityAsSymbol < ActiveRecord::Migration[5.2]
  def up
    device_docs = ActiveFedora::SolrService.query("has_model_ssim:Device", rows: 999_999)

    device_docs.each do |doc|
      modality_ssim = doc['modality_tesim']
      creator_ssim = doc['creator_tesim']

      ActiveFedora::SolrService.add( { 'id' => doc['id'],
                                       'modality_ssim': { 'set'  => modality_ssim },
                                       'creator_ssim': { 'set'  => creator_ssim }
                                      }, softCommit: true )
    end
  end

  def down
    device_docs = ActiveFedora::SolrService.query("has_model_ssim:Device", rows: 999_999)

    device_docs.each do |doc|
      ActiveFedora::SolrService.add( { 'id' => doc['id'],
                                       'modality_ssim': { 'set'  => nil },
                                       'creator_ssim': { 'set'  => nil }
                                      }, softCommit: true )
    end
  end
end
