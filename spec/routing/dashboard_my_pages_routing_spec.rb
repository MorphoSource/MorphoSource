require 'rails_helper'

RSpec.describe 'dashboard my pages routing', type: :routing do

  it 'has a my teams route' do
    route = { controller: 'hyrax/my/teams', action: 'index' }
    expect(:get => '/dashboard/my/teams').to route_to(route)
  end

  it 'has a my projects route' do
    route = { controller: 'hyrax/my/teams', action: 'index' }
    expect(:get => '/dashboard/my/projects').to route_to(route)
  end

  it 'has my media and bso and cho routes' do
    route = { controller: 'hyrax/my/media_works', action: 'index' }
    expect(:get => '/dashboard/my/media').to route_to(route)

    route = { controller: 'hyrax/my/media_works', "action"=>"specimens" }
    expect(:get => '/dashboard/my/media/specimens').to route_to(route)

    route = { controller: 'hyrax/my/media_works', "action"=>"chos" }
    expect(:get => '/dashboard/my/media/chos').to route_to(route)
  end

end
