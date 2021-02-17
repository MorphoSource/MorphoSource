require 'rails_helper'

RSpec.describe 'Contributor routing', type: :routing do

  it 'has a route to grant contributor status' do
    route = { controller: 'contributors', action: 'make_contributor', id: 'abc'}
    expect(:post => 'users/abc/make_contributor').to route_to(route)
  end

  it 'has a route to remove contributor status' do
    route = { controller: 'contributors', action: 'remove_contributor', id: 'abc'}
    expect(:post => 'users/abc/remove_contributor').to route_to(route)
  end
end
