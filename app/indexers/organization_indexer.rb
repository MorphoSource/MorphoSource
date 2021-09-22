# Generated via
#  `rails generate hyrax:work Organization`
class OrganizationIndexer < Morphosource::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  def generate_solr_document
   super.tap do |solr_doc|
     solr_doc['organization_type_ssim'] = object.organization_type
     solr_doc['institution_name_ssim'] = object.institution_name
     solr_doc['institution_code_ssim'] = object.institution_code
     solr_doc['country_ssim'] = object.country
     solr_doc['state_province_ssim'] = object.state_province
     solr_doc['city_ssim'] = object.city
   end
  end
end
