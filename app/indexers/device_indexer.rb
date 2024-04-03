# Generated via
#  `rails generate hyrax:work Device`
class DeviceIndexer < Morphosource::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['creator_ssim'] = object.creator
      solr_doc['ark_ssim'] = object.ark
      if (device_organization = object.organization).present?
        solr_doc["device_organization_id_tesim"] = device_organization.id
        solr_doc["device_organization_id_ssim"] = device_organization.id
        solr_doc["device_organization_title_tesim"] = device_organization.title
        solr_doc["device_organization_title_ssi"] = device_organization.title
        solr_doc["device_organization_institution_name_tesim"] = device_organization.institution_name
        solr_doc["device_organization_institution_name_ssim"] = device_organization.institution_name
      end
    end
  end
end
