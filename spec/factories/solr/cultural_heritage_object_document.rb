# Factory for Biological Specimen physical object SolrDocument instances
CULTURAL_HERITAGE_OBJECT_DOC_ATTRIBUTES = {
  has_model_ssim: ["CulturalHeritageObject"],
  title_tesim: ["Example CHO title"],
  title_ssi: "Example CHO title",
  catalog_number_tesim: ["100"],
  cho_type_tesim: ["Clay pot"],
  collection_code_tesim: ["CC"],
  human_readable_type_tesim: ["Cultural Heritage Object"],
  institution_code_tesim: ["IC"],
  material_tesim: ["Clay"],
  short_title_tesim: ["Short CHO Title"],
  vouchered_tesim: ["Yes"]
}

FactoryBot.define do
  factory :cultural_heritage_object_document, class: "SolrDocument" do
    sequence(:id, 220000) { |n| n.to_s.rjust(9, "0") } # sequence ids starting at '000220000'
    initialize_with { new(CULTURAL_HERITAGE_OBJECT_DOC_ATTRIBUTES.merge({'id': id})) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end