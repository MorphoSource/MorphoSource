module Qa::Authorities
  # Find organization with organization type including object collection
  class FindObjectOrganizations < Qa::Authorities::FindOrganizations
    self.search_builder_class = Morphosource::Qa::FindObjectOrganizationsSearchBuilder
  end
end