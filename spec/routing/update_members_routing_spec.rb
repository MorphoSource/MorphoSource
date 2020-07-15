require 'rails_helper'
# override hyrax update members route

RSpec.describe 'update collection members routing', type: :routing do

  it 'has a route to add member works to a collection' do
    route = { controller: 'morphosource/dashboard/collection_members', action: 'update_members', id: ':id' }
    expect(:post => 'dashboard/collections/:id').to route_to(route)
  end
end
