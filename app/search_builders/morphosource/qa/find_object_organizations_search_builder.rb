# Search builder for Qa::Authority::FindObjectOrganizations
class Morphosource::Qa::FindObjectOrganizationsSearchBuilder < Morphosource::FindOrganizationsSearchBuilder
  self.default_processor_chain += [:organization_type_object_collection]

  def organization_type_object_collection(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << 'organization_type_tesim:("Museum, Department, or Lab Collection" OR "Collection and Scanning Facility")'
  end
end