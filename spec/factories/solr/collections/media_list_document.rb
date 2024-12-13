# Factory for MediaList SolrDocument instances
MEDIA_LIST_DOC_ATTRIBUTES = {
  has_model_ssim: "MediaList",
  visibility_ssi: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
  title_tesim: ["Media List Title"],
  collection_type_gid_ssim: [MediaList.collection_type.gid],
  read_access_group_ssim: ["public"]
}

FactoryBot.define do
  factory :media_list_document, class: "SolrDocument" do
    sequence(:id, 110000) { |n| n.to_s.rjust(9, "0") } # sequence ids starting at '000110000'
    initialize_with { new(MEDIA_LIST_DOC_ATTRIBUTES.merge({'id': id})) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end