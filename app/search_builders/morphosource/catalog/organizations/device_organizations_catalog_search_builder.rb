# Search builder for organizations that manage objects (based on organization type values)
class Morphosource::Catalog::Organizations::DeviceOrganizationsCatalogSearchBuilder < Morphosource::Catalog::OrganizationsCatalogSearchBuilder
  self.default_processor_chain += [:organization_type_device_facility]

  def organization_type_device_facility(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << 'organization_type_tesim:("Scanning Facility" OR "Collection and Scanning Facility")'
  end
end