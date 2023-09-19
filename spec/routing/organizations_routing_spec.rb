require 'rails_helper'

# These apply to organization works, we want to make sure that none of these get overwritten for organization collections for now.

RSpec.describe 'Organization work routing', type: :routing do

  it 'has a create organization route' do
    route = { controller: 'hyrax/organizations', action: 'create' }
    expect(:post => 'concern/organizations').to route_to(route)
  end

  it 'has a new organization route' do
    route = { controller: 'hyrax/organizations', action: 'new' }
    expect(:get => 'concern/organizations/new').to route_to(route)
  end

  it 'has an edit organization route' do
    route = { controller: 'hyrax/organizations', action: 'edit', id: 'foobar'}
    expect(:get => 'concern/organizations/foobar/edit').to route_to(route)
  end

  it 'has a show organization route' do
    route = { controller: 'hyrax/organizations', action: 'show', id: 'foobar'}
    expect(:get => 'concern/organizations/foobar').to route_to(route)
  end

  it 'has an update organization route' do
    route = { controller: 'hyrax/organizations', action: 'update', id: 'foobar'}
    expect(:patch => 'concern/organizations/foobar').to route_to(route)
  end

  it 'has an update organization route' do
    route = { controller: 'hyrax/organizations', action: 'update', id: 'foobar'}
    expect(:put => 'concern/organizations/foobar').to route_to(route)
  end

  it 'has a destroy organization route' do
    route = { controller: 'hyrax/organizations', action: 'destroy', id: 'foobar'}
    expect(:delete => 'concern/organizations/foobar').to route_to(route)
  end

  it 'has an organization manifest route' do
    route = { controller: 'hyrax/organizations', action: 'manifest', id: 'foobar'}
    expect(:get => 'concern/organizations/foobar/manifest').to route_to(route)
  end

  it 'has an organization file manager route' do
    route = { controller: 'hyrax/organizations', action: 'file_manager', id: 'foobar'}
    expect(:get => 'concern/organizations/foobar/file_manager').to route_to(route)
  end

  it 'has an organization inspect work route' do
    route = { controller: 'hyrax/organizations', action: 'inspect_work', id: 'foobar'}
    expect(:get => 'concern/organizations/foobar/inspect_work').to route_to(route)
  end

  it 'has an organization specimens route' do
    route = { controller: 'hyrax/organizations', action: 'specimens', id: 'foobar'}
    expect(:get => 'concern/organizations/specimens/foobar').to route_to(route)
  end

  it 'has an organization chos route' do
    route = { controller: 'hyrax/organizations', action: 'chos', id: 'foobar'}
    expect(:get => 'concern/organizations/chos/foobar').to route_to(route)
  end

  it 'has a create parent organization route' do
    route = { controller: 'hyrax/organizations', action: 'create', parent_id: 'foobar' }
    expect(:post => 'concern/parent/foobar/organizations').to route_to(route)
  end

  it 'has a new parent organization route' do
    route = { controller: 'hyrax/organizations', action: 'new', parent_id: 'foobar' }
    expect(:get => 'concern/parent/foobar/organizations/new').to route_to(route)
  end

  it 'has an edit parent organization route' do
    route = { controller: 'hyrax/organizations', action: 'edit', parent_id: 'foo', id: 'bar' }
    expect(:get => 'concern/parent/foo/organizations/bar/edit').to route_to(route)
  end

  it 'has a show parent organization route' do
    route = { controller: 'hyrax/organizations', action: 'show', parent_id: 'foo', id: 'bar' }
    expect(:get => 'concern/parent/foo/organizations/bar').to route_to(route)
  end

  it 'has an update parent organization route' do
    route = { controller: 'hyrax/organizations', action: 'update', parent_id: 'foo', id: 'bar' }
    expect(:patch => 'concern/parent/foo/organizations/bar').to route_to(route)

  end

  it 'has an update parent organization route' do
    route = { controller: 'hyrax/organizations', action: 'update', parent_id: 'foo', id: 'bar' }
    expect(:put => 'concern/parent/foo/organizations/bar').to route_to(route)
  end

  it 'has a destroy parent organization route' do
    route = { controller: 'hyrax/organizations', action: 'destroy', parent_id: 'foo', id: 'bar' }
    expect(:delete => 'concern/parent/foo/organizations/bar').to route_to(route)
  end

  it 'has an api organizations route' do
    route = { controller: 'organizations_catalog', action: 'index', format: 'json' }
    expect(:get => 'api/organizations').to route_to(route)
  end
end
