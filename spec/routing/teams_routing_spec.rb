require 'rails_helper'

RSpec.describe 'teams/projects routing', type: :routing do

  it 'has a teams route' do
    route = { controller: 'hyrax/teams', action: 'show', id: '12345' }
    expect(:get => '/teams/12345').to route_to(route)
  end

  it 'has a projects route' do
    route = { controller: 'hyrax/teams', action: 'show', id: '12345' }
    expect(:get => '/projects/12345').to route_to(route)
  end

end
