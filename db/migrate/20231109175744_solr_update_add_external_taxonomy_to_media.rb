class SolrUpdateAddExternalTaxonomyToMedia < ActiveRecord::Migration[5.2]
  def up
    # Add external_taxonomy to Media, and make taxonomy uniq
    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999)
    specimen_docs = ActiveFedora::SolrService.query("has_model_ssim:BiologicalSpecimen", rows: 999_999, fl: ["id", "external_taxonomy_ssim", "taxonomy_ssim"])

    specimen_id_to_taxonomy = specimen_docs.each_with_object({}) do |doc, hash|
      hash[doc["id"]] = { external_taxonomy: doc["external_taxonomy_ssim"], taxonomy: doc["taxonomy_ssim"] }
    end

    media_docs.each do |doc|
      specimen_taxonomy = specimen_id_to_taxonomy[doc["physical_object_id_tesim"]&.first] || {}
      external_taxonomy = (specimen_taxonomy[:external_taxonomy] || []).uniq
      taxonomy = (specimen_taxonomy[:taxonomy] || []).uniq

      ActiveFedora::SolrService.add(
        {
          "id" => doc["id"],
          "external_taxonomy_tesim" => { "set" => external_taxonomy },
          "external_taxonomy_ssim" => { "set" => external_taxonomy },
          "taxonomy_tesim" => { "set" => taxonomy },
          "taxonomy_ssim" => { "set" => taxonomy },
        },
        softCommit: true
      )
    end
  end

  def down
    # Remove external_taxonomy from Media, return taxonomy to duplicated state
    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999)
    specimen_docs = ActiveFedora::SolrService.query("has_model_ssim:BiologicalSpecimen", rows: 999_999, fl: ["id", "external_taxonomy_ssim", "taxonomy_ssim"])

    specimen_id_to_taxonomy = specimen_docs.each_with_object({}) do |doc, hash|
      hash[doc["id"]] = { external_taxonomy: doc["external_taxonomy_ssim"], taxonomy: doc["taxonomy_ssim"] }
    end

    media_docs.each do |doc|
      specimen_taxonomy = specimen_id_to_taxonomy[doc["physical_object_id_tesim"]&.first] || {}
      taxonomy = (specimen_taxonomy[:taxonomy] || [])

      ActiveFedora::SolrService.add(
        {
          "id" => doc["id"],
          "external_taxonomy_tesim" => { "set" => nil },
          "external_taxonomy_ssim" => { "set" => nil },
          "taxonomy_tesim" => { "set" => taxonomy },
          "taxonomy_ssim" => { "set" => taxonomy },
        },
        softCommit: true
      )
    end
  end
end
