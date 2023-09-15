class SolrUpdateAddMediaListToPhysicalObject < ActiveRecord::Migration[5.2]
  def up
    # Add fields media_member_of_media_list_ids_ssim and media_member_of_sequential_section_list_ids_ssim
    # to physical object solr documents if appropriate

    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999)
    media_hash = media_docs.map { |doc| [ doc["id"], doc ] }.to_h

    po_docs = ActiveFedora::SolrService.query("has_model_ssim:(BiologicalSpecimen OR CulturalHeritageObject)", rows: 999_999)
    po_to_media = media_hash.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(id, doc), hsh|
      ( doc["physical_object_id_ssim"] || [] ).each do |po_id|
        hsh[po_id] << id
      end
    end

    po_docs.each do |doc|
      if (po_media_ids = po_to_media[doc["id"]]).present?
        if (po_media_docs = media_hash.values_at(*po_media_ids).compact).present?
          media_list_ids = po_media_docs.map { |doc| doc["member_of_media_list_ids_ssim"] }.flatten.compact.uniq
          seqse_list_ids = po_media_docs.map { |doc| doc["member_of_sequential_section_list_ids_ssim"] }.flatten.compact.uniq
          if media_list_ids.present? || seqse_list_ids.present?
            new_doc = { "id" => doc["id"] }
            new_doc["media_member_of_media_list_ids_ssim"] = { "set" => media_list_ids } if media_list_ids.present?
            new_doc["media_member_of_sequential_section_list_ids_ssim"] = { "set" => seqse_list_ids } if seqse_list_ids.present?
            ActiveFedora::SolrService.add(new_doc, softCommit: true)
          end
        end
      end
    end
  end

  def down
    # Remove fields media_member_of_media_list_ids_ssim and media_member_of_sequential_section_list_ids_ssim
    # from all physical objects

    po_docs = ActiveFedora::SolrService.query("has_model_ssim:(BiologicalSpecimen OR CulturalHeritageObject)", rows: 999_999)
    po_docs.each do |doc|
      ActiveFedora::SolrService.add(
        {
          "id" => doc["id"],
          "media_member_of_media_list_ids_ssim" => { "set" => nil },
          "media_member_of_sequential_section_list_ids_ssim" => { "set" => nil },
        },
        softCommit: true
      )
    end
  end
end
