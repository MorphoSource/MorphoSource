# Factory for OrganizationCollection SolrDocument instances
ORGANIZATION_DOC_ATTRIBUTES = {
  has_model_ssim: "OrganizationCollection",
  title_tesim: ["Organization Title"],
  institution_name_tesim: ["Institution Name"],
  display_name_ssi: "Institution Name - Organization Title"
}

FactoryBot.define do
  factory :organization_collection_document, class: "SolrDocument" do
    sequence(:id, 100000) { |n| n.to_s.rjust(9, "0") } # sequence ids starting at '000100000'
    initialize_with { new(ORGANIZATION_DOC_ATTRIBUTES) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end