module Qa::Authorities
  # Find organization with organization type including scanning facility and include device info with output
  class FindDeviceOrganizations < Qa::Authorities::FindOrganizationsWithDevices
    self.search_builder_class = Morphosource::Qa::FindDeviceOrganizationsSearchBuilder
  end
end