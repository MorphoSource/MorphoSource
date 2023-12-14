class StoreSpecimenOccurrenceIdAsSsim < ActiveRecord::Migration[5.2]
  def up
    specimen_docs = ActiveFedora::SolrService.query("has_model_ssim:BiologicalSpecimen", rows: 999_999)

    specimen_docs.each do |doc|
      occurrence_id_ssim = doc['occurrence_id_tesim']

      ActiveFedora::SolrService.add( { 'id' => doc['id'],
                                       'occurrence_id_ssim': { 'set'  => occurrence_id_ssim }
                                      }, softCommit: true )
    end
  end

  def down
    specimen_docs = ActiveFedora::SolrService.query("has_model_ssim:BiologicalSpecimen", rows: 999_999)

    specimen_docs.each do |doc|
      ActiveFedora::SolrService.add( { 'id': doc['id'],
                                        'occurrence_id_ssim': { 'set' => nil }
                                      }, softCommit: true )
    end
  end
end
