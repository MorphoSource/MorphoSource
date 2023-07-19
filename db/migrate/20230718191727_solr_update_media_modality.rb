# Add new Solr Media files modality_ssim and human_readable_modality_tesim
class SolrUpdateMediaModality < ActiveRecord::Migration[5.2]
  def up
    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999)
    ie_docs = ActiveFedora::SolrService.query("has_model_ssim:ImagingEvent", rows: 999_999)
    ie_hash = ie_docs.map { |doc| [doc["id"], doc] }.to_h

    media_docs.each do |doc|
      new_doc = doc.to_h

      # Update new_doc as appropriate
      if (
        new_doc["imaging_event_id_tesim"].present? && 
        !new_doc["modality_ssim"].present? &&
        (ie = ie_hash[new_doc["imaging_event_id_tesim"]&.first]).present? &&
        ie["ie_modality_tesim"].present?
      )
        new_doc["modality_ssim"] = ie["ie_modality_tesim"]
      end

      if (
        new_doc["media_modality_tesim"].present? && 
        !new_doc["human_readable_modality_tesim"].present?
      )
        new_doc["human_readable_modality_tesim"] = new_doc["media_modality_tesim"]
        new_doc["media_modality_tesim"] = nil
        new_doc["media_modality_ssim"] = nil
      end
      
      # Commit new_doc to Solr
      ActiveFedora::SolrService.add(new_doc, softCommit: true)
    end
  end

  def down
    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999)
    media_docs.each do |doc|
      new_doc = doc.to_h
      
      # Update new_doc as appropriate
      if new_doc["human_readable_modality_tesim"].present?
        new_doc["media_modality_tesim"] = new_doc["human_readable_modality_tesim"]
        new_doc["media_modality_ssim"] = new_doc["human_readable_modality_tesim"]
        new_doc["human_readable_modality_tesim"] = nil
      end
      new_doc["modality_ssim"] = nil

      # Commit new_doc to Solr
      ActiveFedora::SolrService.add(new_doc, softCommit: true)
    end
  end
end
