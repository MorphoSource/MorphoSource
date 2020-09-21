require 'rails_helper'

RSpec.describe 'browse pages routing', type: :routing do

  it 'has a browse teams  route' do
    route = { controller: 'hyrax/browse_teams', action: 'index' }
    expect(:get => '/browse/teams').to route_to(route)
  end

  it 'has a browse projects route' do
    route = { controller: 'hyrax/browse_teams', action: 'index' }
    expect(:get => '/browse/projects').to route_to(route)
  end

  it 'has a browse organizations route' do
    route = { controller: 'hyrax/browse_organizations', action: 'index' }
    expect(:get => '/browse/organizations').to route_to(route)
  end

  it 'has a browse media_types_and_modalities route' do
    route = { controller: 'hyrax/browse', action: 'media_types_and_modalities' }
    expect(:get => '/browse/media_types_and_modalities').to route_to(route)
  end

  it 'has a browse physical_object_types route' do
    route = { controller: 'hyrax/browse', action: 'physical_object_types' }
    expect(:get => '/browse/physical_object_types').to route_to(route)
  end

  it 'has a browse categories route' do
    route = { controller: 'hyrax/browse', action: 'categories' }
    expect(:get => '/browse/categories').to route_to(route)
  end


end
