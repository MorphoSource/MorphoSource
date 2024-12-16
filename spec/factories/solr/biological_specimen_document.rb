# Factory for Biological Specimen physical object SolrDocument instances
BIOLOGICAL_SPECIMEN_DOC_ATTRIBUTES = {
  has_model_ssim: ["BiologicalSpecimen"],
  title_tesim: ["Example media title"],
  title_ssi: "Example media title",
  catalog_number_tesim: ["100"],
  cho_type_tesim: ["Not a culturahl heritage object"],
  collection_code_tesim: ["CC"],
  human_readable_type_tesim: ["Biological Specimen"],
  idigbio_uuid_tesim: ["1234-1234-1234"],
  institution_code_tesim: ["IC"],
  material_tesim: ["Bone"],
  occurrence_id_tesim: ["6789-6789-6789"],
  occurrence_id_ssim: ["6789-6789-6789"],
  short_title_tesim: ["Short Title"],
  vouchered_tesim: ["Yes"]
}

FactoryBot.define do
  factory :biological_specimen_document, class: "SolrDocument" do
    sequence(:id, 210000) { |n| n.to_s.rjust(9, "0") } # sequence ids starting at '000210000'
    initialize_with { new(BIOLOGICAL_SPECIMEN_DOC_ATTRIBUTES.merge({'id': id})) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end