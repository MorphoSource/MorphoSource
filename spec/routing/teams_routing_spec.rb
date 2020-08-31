require 'rails_helper'

RSpec.describe 'teams/projects routing', type: :routing do

  it 'has a teams route' do
    route = { controller: 'hyrax/teams', action: 'show', id: '12345' }
    expect(:get => '/teams/12345').to route_to(route)
  end

  it 'has a teams specimens route' do
    route = { controller: 'hyrax/teams', action: 'specimens', id: '12345' }
    expect(:get => '/teams/specimens/12345').to route_to(route)
  end

  it 'has a teams chos route' do
    route = { controller: 'hyrax/teams', action: 'chos', id: '12345' }
    expect(:get => '/teams/chos/12345').to route_to(route)
  end

  it 'has a projects route' do
    route = { controller: 'hyrax/teams', action: 'show', id: '12345' }
    expect(:get => '/projects/12345').to route_to(route)
  end

  it 'has a projects specimens route' do
    route = { controller: 'hyrax/teams', action: 'specimens', id: '12345' }
    expect(:get => '/projects/specimens/12345').to route_to(route)
  end

  it 'has a projects chos route' do
    route = { controller: 'hyrax/teams', action: 'chos', id: '12345' }
    expect(:get => '/projects/chos/12345').to route_to(route)
  end

  it 'has a dashboard collections specimens route' do
    route = { controller: 'hyrax/dashboard/collections', action: 'specimens', id: '12345' }
    expect(:get => '/dashboard/collections/specimens/12345').to route_to(route)
  end

  it 'has a dashboard collections chos route' do
    route = { controller: 'hyrax/dashboard/collections', action: 'chos', id: '12345' }
    expect(:get => '/dashboard/collections/chos/12345').to route_to(route)
  end

end
