# Factory for Team SolrDocument instances
TEAM_DOC_ATTRIBUTES = {
  has_model_ssim: "Collection",
  visibility_ssi: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
  title_tesim: ["Team Title"],
  read_access_group_ssim: ["public"]
}

FactoryBot.define do
  factory :team_document, class: "SolrDocument" do
    sequence(:id, 150000) { |n| n.to_s.rjust(9, "0") } # sequence ids starting at '000150000'
    initialize_with { new(TEAM_DOC_ATTRIBUTES.merge({'id': id}).merge(attributes)) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end