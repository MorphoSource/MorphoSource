require 'rails_helper'

RSpec.describe 'linked teams routing', type: :routing do
  it 'has a route to link teams and organizations' do
    route = { controller: 'morphosource/dashboard/linked_teams', action: "link_organization", id: ':id' }
    expect(:post => 'dashboard/collections/:id/organizations').to route_to(route)
  end

  it 'has a route to search unlinked organizations' do
    route = { controller: 'hyrax/organizations', action: 'unlinked_organizations' }
    expect(:get => 'unlinked_organizations').to route_to(route)
  end
end
