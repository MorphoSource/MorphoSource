# Factory for OrganizationCollection SolrDocument instances
ORGANIZATION_DOC_ATTRIBUTES = {
  has_model_ssim: "OrganizationCollection",
  visibility_ssi: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
  title_tesim: ["Organization Title"],
  institution_name_tesim: ["Institution Name"],
  display_name_ssi: "Institution Name - Organization Title",
  read_access_group_ssim: ["public"]
}

FactoryBot.define do
  factory :organization_collection_document, class: "SolrDocument" do
    sequence(:id, 120000) { |n| n.to_s.rjust(9, "0") } # sequence ids starting at '000120000'
    initialize_with { new(ORGANIZATION_DOC_ATTRIBUTES.merge({'id': id}).merge(attributes)) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end