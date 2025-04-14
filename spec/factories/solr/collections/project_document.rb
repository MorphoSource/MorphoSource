# Factory for Project SolrDocument instances
PROJECT_DOC_ATTRIBUTES = {
  has_model_ssim: "Collection",
  visibility_ssi: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
  title_tesim: ["Project Title"],
  read_access_group_ssim: ["public"]
}

FactoryBot.define do
  factory :project_document, class: "SolrDocument" do
    sequence(:id, 130000) { |n| n.to_s.rjust(9, "0") } # sequence ids starting at '000130000'
    initialize_with { new(PROJECT_DOC_ATTRIBUTES.merge({'id': id}).merge(attributes)) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end