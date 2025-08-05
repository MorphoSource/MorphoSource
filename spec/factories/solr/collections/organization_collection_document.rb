# Factory for OrganizationCollection SolrDocument instances
ORGANIZATION_DOC_ATTRIBUTES = {
  has_model_ssim: "OrganizationCollection",
  visibility_ssi: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
  collection_type_gid_ssim: [Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Organizations::SETTINGS).to_global_id.uri],
  title_tesim: ["Organization Title"],
  institution_name_tesim: ["Institution Name"],
  human_readable_type_tesim: ["Organization"],
  has_model_ssim: ["OrganizationCollection"],
  display_name_ssi: "Institution Name - Organization Title"
}

FactoryBot.define do
  factory :organization_collection_document, class: "SolrDocument" do
    sequence(:id, 120000) { |n| n.to_s.rjust(9, "0") } # sequence ids starting at '000120000'
    initialize_with { new(ORGANIZATION_DOC_ATTRIBUTES.merge({'id': id,
                                                             'edit_access_group_ssim': ["#{id}_managers", 'admin'],
                                                             'read_access_group_ssim': ["#{id}_viewers", "#{id}_editors", "#{id}_downloaders", "#{id}_depositors", 'public']
                                                            }).merge(attributes)) }
    to_create { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true)}
  end
end