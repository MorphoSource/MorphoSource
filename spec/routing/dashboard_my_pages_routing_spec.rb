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

  it 'has my media, add media, bso and cho routes' do
    route = { controller: 'morphosource/my/media', action: 'index' }
    expect(:get => '/dashboard/my/media').to route_to(route)

    route = { controller: 'morphosource/my/add_media', action: 'index', collection_id: 'foobar' }
    expect(:get => '/dashboard/my/media/foobar').to route_to(route)

    route = { controller: 'morphosource/my/biological_specimens', action: 'index' }
    expect(:get => '/dashboard/my/specimens').to route_to(route)

    route = { controller: 'morphosource/my/cultural_heritage_objects', action: 'index' }
    expect(:get => '/dashboard/my/cultural_heritage_objects').to route_to(route)
  end

end
