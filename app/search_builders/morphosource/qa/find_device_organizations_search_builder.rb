# Search builder for Qa::Authority::FindDeviceOrganizations
class Morphosource::Qa::FindDeviceOrganizationsSearchBuilder < Morphosource::FindOrganizationsSearchBuilder
  self.default_processor_chain += [:organization_type_device_facility]

  def organization_type_device_facility(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << 'organization_type_tesim:("Scanning Facility" OR "Collection and Scanning Facility")'
  end
end