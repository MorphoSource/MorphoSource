# Factory for Media SolrDocument instances
PRIVATE_MEDIA_DOC_ATTRIBUTES = {
  has_model_ssim: ["Media"],
  title_tesim: ["Example media title"],
  title_ssi: "Example media title",
  visibility_ssi: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE,
  fileset_accessibility_tesim: ["private"],
  fileset_accessibility_ssim: ["private"],
  fileset_visibility_tesim: [""],
  file_set_visibilities_ssim: ["private"],
  depositor_ssim: ["123456"],
  depositor_tesim: ["123456"],
  accessControl_ssim: ["4fbd8dac-6c76-4f26-95a8-e3bf89e2a1a3"],
  agreement_uri_tesim: ["https://www.google.com"],
  ark_ssim: ["ark"],
  ark_tesim: ["ark"],
  cite_as_tesim: ["Cite As Media"],
  description_tesim: ["Description"],
  doi_ssim: ["doi"],
  doi_tesim: ["doi"],
  download_reviewer_tesim: ["123456"],
  download_reviewers_ssim: ["123456"],
  file_set_ids_ssim: ["678912345"],
  funding_tesim: ["Funding"],
  hasRelatedMediaFragment_ssim: ["678912345"],
  identifier_tesim: ["Identifier"],
  imaging_event_id_tesim: ["234567891"],
  is_remote_backed_bsi: false,
  map_type_tesim: ["Color"],
  member_ids_ssim: ["678912345"],
  media_organization_id_tesim: ["345678912"],
  media_organization_id_ssim: ["345678912"],
  media_type_tesim: ["CTImageSeries"],
  morphosource_use_agreement_type_tesim: ["Standard"],
  number_of_images_in_set_tesim: ["1500"],
  organization_transfer_on_publish_bsi: false,
  pending_org_transfer_bsi: false,
  orientation_tesim: ["Sagittal"],
  part_tesim: ["Cranium"],
  permits_3d_use_tesim: ["3DPrintingLimited"],
  permits_commercial_use_tesim: ["CommercialUseNotPermitted"],
  physical_object_id_tesim: ["456789123"],
  physical_object_id_ssim: ["456789123"],
  media_physical_object_type_tesim: ["Biological Specimen"],
  media_physical_object_type_ssim: ["Biological Specimen"],
  preview_mode_tesim: ["Interactive/Embeddable"] ,
  publication_status_ssi: "Private",
  related_url_tesim: ["https://www.google.com"],
  remote_manifest_url_tesim: ["https://www.google.com"],
  remote_manifest_url_ssi: "https://www.google.com",
  remote_origin_url_tesim: ["https://www.google.com"],
  required_archival_of_published_derivatives_tesim: ["OnMorphoSource"],
  rights_holder_tesim: ["Rights Holder"],
  scale_bar_tesim: ["Scale bar"],
  series_type_tesim: ["Scale bar type"],
  short_description_tesim: ["Short description"],
  side_tesim: ["Left"],
  slice_thickness_tesim: ["0.1"],
  taxonomy_ssim: ["Indri indri"],
  unit_tesim: ["Mm"],
  user_with_ownership_ssi: "123456",
  x_spacing_tesim: ["0.1"],
  y_spacing_tesim: ["0.1"],
  z_spacing_tesim: ["0.1"]
}

PUBLIC_MEDIA_DOC_ATTRIBUTES = PRIVATE_MEDIA_DOC_ATTRIBUTES.merge( {
  visibility_ssi: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
  fileset_accessibility_tesim: ["open"],
  fileset_accessibility_ssim: ["open"],
  fileset_visibility_tesim: [""],
  file_set_visibilities_ssim: ["open"],
  read_access_group_ssim: ["public"]
} )

CHO_MEDIA_DOC_ATTRIBUTES = PRIVATE_MEDIA_DOC_ATTRIBUTES.merge( {
  media_physical_object_type_tesim: ["Cultural Heritage Object"],
  media_physical_object_type_ssim: ["Cultural Heritage Object"]
} )

FactoryBot.define do
  factory :media_document, class: "SolrDocument", aliases: [:private_media_document] do
    sequence(:id, 100000) { |n| n.to_s.rjust(9, "0") } # sequence ids starting at '000100000'
    initialize_with       { new(PRIVATE_MEDIA_DOC_ATTRIBUTES.merge({'id': id}).merge(attributes)) }
    to_create             { |instance| ActiveFedora::SolrService.add(instance.to_h, softCommit: true) }

    factory :public_media_document do
      initialize_with     { new(PUBLIC_MEDIA_DOC_ATTRIBUTES.merge({'id': id})) }
    end

    factory :cho_media_document do
      initialize_with     { new(CHO_MEDIA_DOC_ATTRIBUTES.merge({'id': id})) }
    end
  end
end