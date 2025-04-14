# Factory for SequentialSectionList SolrDocument instances
SEQUENTIAL_SECTION_LIST_DOC_ATTRIBUTES = {
  has_model_ssim: "SequentialSectionList",
  visibility_ssi: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
  title_tesim: ["Sequential Section List Title"],
  read_access_group_ssim: ["public"]
}

FactoryBot.define do
  factory :sequential_section_list_document, class: "SolrDocument" do
    sequence(:id, 140000) { |n| n.to_s.rjust(9, "0") } # sequence ids starting at '000140000'
    initialize_with { new(SEQUENTIAL_SECTION_LIST_DOC_ATTRIBUTES.merge({'id': id}).merge(attributes)) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end