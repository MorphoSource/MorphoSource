module Hyrax::Browse::BrowseOrganizationsHelper

  def browse_service
    @browse_service ||= Morphosource::BrowseService.new
  end

  def total_scanning_facilities
    return browse_service.organization_count_by_type("Scanning Facility")
  end

  def total_collection_and_scanning_facilities
    return browse_service.organization_count_by_type("Collection and Scanning Facility")
  end

end
