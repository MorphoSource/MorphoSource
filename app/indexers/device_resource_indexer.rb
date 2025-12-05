# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource DeviceResource`
class DeviceResourceIndexer < Hyrax::Indexers::PcdmObjectIndexer(DeviceResource)
  include Hyrax::Indexer(:basic_metadata)
  include Hyrax::Indexer(:device_resource)

  def to_solr
    super.tap do |solr_doc|
      solr_doc['creator_ssim'] = Array(resource.creator)
      solr_doc['ark_tesim'] = Array(resource.ark)
      solr_doc['ark_ssim'] = Array(resource.ark)

      if (device_organization = resource.organization).present?
        solr_doc['device_organization_id_tesim'] = device_organization.id
        solr_doc['device_organization_id_ssim'] = device_organization.id
        solr_doc['device_organization_title_tesim'] = device_organization.title
        solr_doc['device_organization_title_ssi'] = device_organization.title
        solr_doc['device_organization_institution_name_tesim'] = device_organization.institution_name
        solr_doc['device_organization_institution_name_ssim'] = device_organization.institution_name
      end
    end
  end
end
