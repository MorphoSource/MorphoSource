class SolrUpdateHumanReadableMediaType < ActiveRecord::Migration[5.2]
  def up
    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999, fl: ["id", "media_type_ssim"])
    media_docs.each do |doc|
      media_type = doc["media_type_ssim"]
      human_readable_media_type = [Morphosource::MediaTypesService.short_term(media_type&.first) || "Unknown Type"]

      ActiveFedora::SolrService.add({ "id" => doc["id"],
                                      "human_readable_media_type_tesim": { "set"  => human_readable_media_type },
                                      "human_readable_media_type_ssim": { "set"  => human_readable_media_type }
                                    }, softCommit: true )
    end

    update_objects
  end

  def down
    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999, fl: ["id", "media_type_ssim"])
    media_docs.each do |doc|
      media_type = doc["media_type_ssim"]
      human_readable_media_type = prev_human_readable_label(media_type)

      ActiveFedora::SolrService.add({ "id" => doc["id"],
                                      "human_readable_media_type_tesim": { "set"  => human_readable_media_type },
                                      "human_readable_media_type_ssim": { "set"  => human_readable_media_type }
                                    }, softCommit: true )
    end

    update_objects
  end

  # Update object index media type fields using most recent media
  def update_objects
    media_docs = ActiveFedora::SolrService.query("has_model_ssim:Media", rows: 999_999, fl: ["id", "human_readable_media_type_ssim", "visibility_ssi", "physical_object_id_ssim"])
    obj_to_media = media_docs.each_with_object({}) do |doc, hash|
      obj_id = doc["physical_object_id_ssim"]&.first
      if obj_id
        (hash[obj_id] ||= []).push(doc)
      end
    end
 
    object_docs = ActiveFedora::SolrService.query("has_model_ssim:(BiologicalSpecimen OR CulturalHeritageObject)", rows: 999_999)
    object_docs.each do |doc|
      public_object_media = ( obj_to_media[doc["id"]] || [] ).select { |m| m["visibility_ssi"] == "open" }
      public_human_readable_media_types = ( public_object_media || [] ).map { |d| d["human_readable_media_type_ssim"] }.flatten.compact.uniq
      if public_human_readable_media_types
        ActiveFedora::SolrService.add({ "id" => doc["id"],
                                        "public_media_type_tesim": { 'set'  => public_human_readable_media_types },
                                        "public_media_type_ssim": { 'set'  => public_human_readable_media_types },
                                      }, softCommit: true )
      end
    end
  end

  # Defunct behavior for generating human readable media type from media type id
  def prev_human_readable_label(media_type)
    case media_type&.first
    when "CTImageSeries"
      ["CT Image Series"]
    when "PhotogrammetryImageSeries"
      ["Photogrammetry Image Series"]
    else
      [ media_type&.first || "Unknown Type" ]
    end
  end
end
