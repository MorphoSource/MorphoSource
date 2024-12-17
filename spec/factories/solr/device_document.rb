# Factory for Device SolrDocument instances
DEVICE_DOC_ATTRIBUTES = {
  id: "567891234",
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
    initialize_with { new(DEVICE_DOC_ATTRIBUTES) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end