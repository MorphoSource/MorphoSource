class StoreTaxonomyGbifKeyAsSsim < ActiveRecord::Migration[5.2]
  def up
    taxonomy_docs = ActiveFedora::SolrService.query("has_model_ssim:Taxonomy", rows: 999_999)

    taxonomy_docs.each do |doc|
      gbif_key_ssim = doc['gbif_key_tesim']

      ActiveFedora::SolrService.add( { 'id' => doc['id'],
                                       'gbif_key_ssim': { 'set'  => gbif_key_ssim }
                                      }, softCommit: true )
    end
  end

  def down
    taxonomy_docs = ActiveFedora::SolrService.query("has_model_ssim:Taxonomy", rows: 999_999)

    taxonomy_docs.each do |doc|
      ActiveFedora::SolrService.add( { 'id': doc['id'],
                                        'gbif_key_ssim': { 'set' => nil }
                                      }, softCommit: true )
    end
  end
end
