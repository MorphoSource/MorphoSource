# Factory for Processing Event SolrDocument instances
PROCESSING_EVENT_DOC_ATTRIBUTES = {
  has_model_ssim: ["ProcesingEvent"],
  visibility_ssi: "open"
}

FactoryBot.define do
  factory :processing_event_document, class: "SolrDocument" do
    sequence(:id, 260000) { |n| n.to_s.rjust(9, "0") } # sequence ids starting at '000260000'
    initialize_with { new(PROCESSING_EVENT_DOC_ATTRIBUTES.merge({'id': id})) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end