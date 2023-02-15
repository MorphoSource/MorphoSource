# frozen_string_literal: true
collection_ids = @document_list.map(&:id)
collections = ActiveFedora::Base.find(collection_ids)
byebug
json.array! collections do |collection|
  json.id collection.id
  json.label collection.title
  json.machine_id collection.collection_type.machine_id

  if collection.media_docs.present?
    json.object_id collection.media_docs.first["physical_object_id_ssim"]
  else
    json.object_id []
  end
end

