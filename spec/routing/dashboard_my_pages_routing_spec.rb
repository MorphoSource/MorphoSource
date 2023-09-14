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

  it 'has my media routes' do
    # index
    route = { controller: 'morphosource/my/media', action: 'index' }
    expect(:get => '/dashboard/my/media').to route_to(route)
    # facet
    route = { controller: 'morphosource/my/media', action: 'facet', id: 'foobar' }
    expect(:get => '/dashboard/my/media/facet/foobar').to route_to(route)
  end

  it 'has my add media routes' do
    # index
    route = { controller: 'morphosource/my/add_media', action: 'index', collection_id: 'foobar' }
    expect(:get => '/dashboard/my/media/foobar').to route_to(route)
    # facet
    route = { controller: 'morphosource/my/add_media', action: 'facet', collection_id: 'foobar', id: 'foobar' }
    expect(:get => '/dashboard/my/media/foobar/facet/foobar').to route_to(route)
  end

  it 'has my specimens routes' do
    # index
    route = { controller: 'morphosource/my/biological_specimens', action: 'index' }
    expect(:get => '/dashboard/my/specimens').to route_to(route)
    # facet
    route = { controller: 'morphosource/my/biological_specimens', action: 'facet', id: 'foobar' }
    expect(:get => '/dashboard/my/specimens/facet/foobar').to route_to(route)
  end

  it 'has my chos routes' do
    # index
    route = { controller: 'morphosource/my/cultural_heritage_objects', action: 'index' }
    expect(:get => '/dashboard/my/cultural_heritage_objects').to route_to(route)
    # facet
    route = { controller: 'morphosource/my/cultural_heritage_objects', action: 'facet', id: 'foobar' }
    expect(:get => '/dashboard/my/cultural_heritage_objects/facet/foobar').to route_to(route)
  end

  it 'has my sequential section lists routes' do
    # index
    route = { controller: 'morphosource/my/collections/media_lists/sequential_section_lists', action: 'index' }
    expect(:get => '/dashboard/my/sequential_section_lists').to route_to(route)
    # facet
    route = { controller: 'morphosource/my/collections/media_lists/sequential_section_lists', action: 'facet', id: 'foobar' }
    expect(:get => '/dashboard/my/sequential_section_lists/facet/foobar').to route_to(route)
  end

end
