# Factory for Device SolrDocument instances
DEVICE_DOC_ATTRIBUTES = {
  has_model_ssim: "Device",
  creator_tesim: ["Scanning Device Make"],
  description_tesim: ["Description"],
  modality_tesim: ["MicroNanoXRayComputedTomography"],
  title_tesim: ["Scanning Device Model"],
  device_organization_title_tesim: ["Collection Name"],
  device_organization_institution_name_tesim: ["Institution Name"]
}

FactoryBot.define do
  factory :device_document, class: "SolrDocument" do
    sequence(:id, 230000) { |n| n.to_s.rjust(9, "0") } # sequence ids starting at '000230000'
    initialize_with { new(DEVICE_DOC_ATTRIBUTES.merge({'id': id})) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end