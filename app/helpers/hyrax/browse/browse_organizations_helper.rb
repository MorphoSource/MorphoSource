module Hyrax::Browse::BrowseOrganizationsHelper

  def browse_service
    @browse_service ||= Morphosource::BrowseService.new
  end

  def org_type_and_count
    @org_type_and_count
  end

  def get_organization_count_by_type
    facets = browse_service.organization_facets
    @org_type_and_count = facets[Solrizer.solr_name('organization_type', :facetable)] 
  end

  def total_collections
  	return @document_list.map { |org| org["team_id_tesim"] }.compact.length
  end

end
