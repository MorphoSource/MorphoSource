# Search builder for organizations that manage objects (based on organization type values)
class Morphosource::Catalog::Organizations::ObjectOrganizationsCatalogSearchBuilder < Morphosource::Catalog::OrganizationsCatalogSearchBuilder
  self.default_processor_chain += [:organization_type_object_collection]

  def organization_type_object_collection(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << 'organization_type_tesim:("Museum, Department, or Lab Collection" OR "Collection and Scanning Facility")'
  end
end