require 'rails_helper'

RSpec.describe 'showcase page routing', type: :routing do


  it 'has new routes to replace default media show page with media showcase page' do
    route = { controller: 'hyrax/media', action: 'showcase', id: ':id' }
    expect(:get => 'concern/media/:id').to route_to(route)
    route = { controller: 'hyrax/media', action: 'showcase', id: ':id', parent_id: ':parent_id' }
    expect(:get => 'concern/parent/:parent_id/media/:id').to route_to(route)
  end

  it 'has correct routes for media for other actions' do
    route = { controller: 'hyrax/media', action: 'new' }
    expect(:get => 'concern/media/new').to route_to(route)
    route = { controller: 'hyrax/media', action: 'zip' }
    expect(:get => 'concern/media/zip').to route_to(route)
  end

  it 'has new routes to replace default biological_specimens show page with biological_specimens showcase page' do
    route = { controller: 'hyrax/biological_specimens', action: 'showcase', id: ':id' }
    expect(:get => 'concern/biological_specimens/:id').to route_to(route)
    route = { controller: 'hyrax/biological_specimens', action: 'showcase', id: ':id', parent_id: ':parent_id' }
    expect(:get => 'concern/parent/:parent_id/biological_specimens/:id').to route_to(route)
  end

  it 'has new routes to replace default cultural_heritage_objects show page with cultural_heritage_objects showcase page' do
    route = { controller: 'hyrax/cultural_heritage_objects', action: 'showcase', id: ':id' }
    expect(:get => 'concern/cultural_heritage_objects/:id').to route_to(route)
    route = { controller: 'hyrax/cultural_heritage_objects', action: 'showcase', id: ':id', parent_id: ':parent_id' }
    expect(:get => 'concern/parent/:parent_id/cultural_heritage_objects/:id').to route_to(route)
  end

  it 'has correct routes for biological_specimens for other actions' do
    route = { controller: 'hyrax/biological_specimens', action: 'new' }
    expect(:get => 'concern/biological_specimens/new').to route_to(route)
  end

  it 'has correct routes for cultural_heritage_objects for other actions' do
    route = { controller: 'hyrax/cultural_heritage_objects', action: 'new' }
    expect(:get => 'concern/cultural_heritage_objects/new').to route_to(route)
  end

end
