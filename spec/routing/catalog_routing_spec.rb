require 'rails_helper'

RSpec.describe 'catalog routing', type: :routing do

  # media
  it 'has a route for searching media' do
    route = { controller: 'media_catalog', action: 'index' }
    expect(get: 'catalog/media').to route_to(route)
  end

  it 'has a route for faceting media' do
    route = { controller: 'media_catalog', action: 'facet', id: 'id' }
    expect(get: 'media_catalog/facet/id').to route_to(route)
  end

  # objects
  it 'has a route for searching objects' do
    route = { controller: 'objects_catalog', action: 'index' }
    expect(get: 'catalog/objects').to route_to(route)
  end

  it 'has a route for faceting objects' do
    route = { controller: 'objects_catalog', action: 'facet', id: 'id' }
    expect(get: 'objects_catalog/facet/id').to route_to(route)
  end

  # organizations
  it 'has a route for searching organizations' do
    route = { controller: 'organizations_catalog', action: 'index' }
    expect(get: 'catalog/organizations').to route_to(route)
  end

  it 'has a route for searching managed organizations by user' do
    route = { controller: 'organizations_catalog', action: 'index', user: '42' }
    expect(get: 'catalog/organizations/managed_by/42').to route_to(route)
  end

  it 'has a route for faceting organizations' do
    route = { controller: 'organizations_catalog', action: 'facet', id: 'id' }
    expect(get: 'organizations_catalog/facet/id').to route_to(route)
  end

  # collections
  it 'has a route for searching collections' do
    route = { controller: 'collections_catalog', action: 'index' }
    expect(get: 'catalog/teams_projects').to route_to(route)
  end

  it 'has a route for faceting collections' do
    route = { controller: 'collections_catalog', action: 'facet', id: 'id' }
    expect(get: 'collections_catalog/facet/id').to route_to(route)
  end

  # all
  it 'has a route for searching all works' do
    route = { controller: 'all_catalog', action: 'index' }
    expect(get: 'catalog/all').to route_to(route)
  end

  it 'has a route for faceting media' do
    route = { controller: 'all_catalog', action: 'facet', id: 'id' }
    expect(get: 'all_catalog/facet/id').to route_to(route)
  end

  # catalog
  it 'routes the default catalog to all' do
    route = { controller: 'all_catalog', action: 'index' }
    expect(get: 'catalog').to route_to(route)
  end
end
