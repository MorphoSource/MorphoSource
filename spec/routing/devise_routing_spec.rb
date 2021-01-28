require 'rails_helper'

RSpec.describe 'devise routing', type: :routing do

  it 'has a edit ms1 password route' do
    route = { controller: 'morphosource/passwords', action: 'ms1_edit' }
    expect(get: '/users/password/ms1_edit').to route_to(route)
  end

  it 'has a regular edit password route' do
    route = { controller: 'devise/passwords', action: 'edit' }
    expect(get: '/users/password/edit').to route_to(route)
  end
end
