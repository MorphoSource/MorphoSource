# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'collection roles routing', type: :routing do
  it "has a route to update a collection's default user groups" do
    route = { controller: 'collection_roles', action: 'update_collection_groups', id: ':id' }
    expect(post: 'dashboard/collections/:id/update_collection_groups').to route_to(route)
  end
end
