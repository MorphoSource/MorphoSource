require 'rails_helper'

RSpec.describe 'collections routing', type: :routing do

  let(:id)            { '12345' }
  let(:collection_id) { 'abcde' }

  # my
  it 'has a my organizations route' do
    route = { controller: 'morphosource/my/collections/organization_collections', action: 'index' }
    expect(:get => "/dashboard/my/organizations").to route_to(route)
  end

  # showcase
  it 'has an organization route' do
    route = { controller: 'morphosource/collections/organization_collections', action: 'show', id: id }
    expect(:get => "/organizations/#{id}").to route_to(route)
  end

  it 'has an organization device media route' do
    route = { controller: 'morphosource/collections/organization_collections/device_media', action: 'show', id: id }
    expect(:get => "/organizations/#{id}/device-media").to route_to(route)
  end

  it 'has an organization specimens route' do
    route = { controller: 'morphosource/collections/organization_collections/physical_objects/biological_specimens', action: 'show', id: id }
    expect(:get => "/organizations/#{id}/biological-specimens").to route_to(route)
  end

  it 'has an organization chos route' do
    route = { controller: 'morphosource/collections/organization_collections/physical_objects/cultural_heritage_objects', action: 'show', id: id }
    expect(:get => "/organizations/#{id}/cultural-heritage-objects").to route_to(route)
  end

  it 'has an organization devices route' do
    route = { controller: 'morphosource/collections/organization_collections/devices', action: 'show', id: id }
    expect(:get => "/organizations/#{id}/devices").to route_to(route)
  end

  it 'has an organization about route' do
    route = { controller: 'morphosource/collections/organization_collections', action: 'about', id: id }
    expect(:get => "/organizations/#{id}/about").to route_to(route)
  end

  it 'has an organization media faceting route' do
    route = { controller: 'morphosource/collections/organization_collections', action: 'facet', id: id, collection_id: collection_id }
    expect(:get => "/organizations/#{collection_id}/facet/#{id}").to route_to(route)
  end

  it 'has an organization specimens faceting route' do
    route = { controller: 'morphosource/collections/organization_collections/physical_objects/biological_specimens', action: 'facet', id: id, collection_id: collection_id }
    expect(:get => "/organizations/#{collection_id}/biological-specimens/facet/#{id}").to route_to(route)
  end

  it 'has an organization chos faceting route' do
    route = { controller: 'morphosource/collections/organization_collections/physical_objects/cultural_heritage_objects', action: 'facet', id: id, collection_id: collection_id }
    expect(:get => "/organizations/#{collection_id}/cultural-heritage-objects/facet/#{id}").to route_to(route)
  end

  it 'has an organization devices faceting route' do
    route = { controller: 'morphosource/collections/organization_collections/devices', action: 'facet', id: id, collection_id: collection_id }
    expect(:get => "/organizations/#{collection_id}/devices/facet/#{id}").to route_to(route)
  end
end

RSpec.describe 'collections dashboard routes', type: :routing do
  let(:id)  { '123' }

  it 'has a details route' do
    route = { controller: 'morphosource/dashboard/collections/organization_collections', action: 'edit', id: id }
    expect(:get => "/dashboard/organizations/#{id}").to route_to(route)
  end
  it 'has a members route' do
    route = { controller: 'morphosource/dashboard/collections/organization_collections', action: 'members', id: id }
    expect(:get => "/dashboard/organizations/#{id}/members").to route_to(route)
  end
  it 'has a permissions route' do
    route = { controller: 'morphosource/dashboard/collections/organization_collections', action: 'permissions', id: id }
    expect(:get => "/dashboard/organizations/#{id}/permissions").to route_to(route)
  end
  it 'has a projects route' do
    route = { controller: 'morphosource/dashboard/collections/organization_collections', action: 'projects', id: id }
    expect(:get => "/dashboard/organizations/#{id}/projects").to route_to(route)
  end
  it 'has a new organization route' do
    route = { controller: 'morphosource/dashboard/collections/organization_collections', action: 'new' }
    expect(:get => "/dashboard/organizations/new").to route_to(route)
  end
  it 'has a create organization route' do
    route = { controller: 'morphosource/dashboard/collections/organization_collections', action: 'create' }
    expect(:post => "/dashboard/organizations").to route_to(route)
  end
  it 'has an update organization route without an id' do
    route = { controller: 'morphosource/dashboard/collections/organization_collections', action: 'update' }
    expect(:put => "/dashboard/organizations").to route_to(route)
  end
  it 'has an update organization route with put' do
    route = { controller: 'morphosource/dashboard/collections/organization_collections', action: 'update', id: id }
    expect(:put => "/dashboard/organizations/#{id}").to route_to(route)
  end
  it 'has an update organization route with patch' do
    route = { controller: 'morphosource/dashboard/collections/organization_collections', action: 'update', id: id }
    expect(:patch => "/dashboard/organizations/#{id}").to route_to(route)
  end
  it 'has an organization files route' do
    route = { controller: 'morphosource/dashboard/collections/organization_collections', action: 'files', id: id }
    expect(:get => "/dashboard/organizations/#{id}/files").to route_to(route)
  end
end


RSpec.describe 'csv exports', type: :routing do

  let(:id)  { '12345' }

  it 'has a media_downloads route' do
    route = { controller: 'morphosource/collections/organization_collections', action: 'media_downloads', id: id }
    expect(:get => "/organizations/#{id}/media_downloads").to route_to(route)
  end

  it 'has a media_requests route' do
    route = { controller: 'morphosource/collections/organization_collections', action: 'media_requests', id: id }
    expect(:get => "/organizations/#{id}/media_requests").to route_to(route)
  end

  it 'has a media_export route' do
    route = { controller: 'morphosource/collections/organization_collections', action: 'media_export_with_intersections_facet', id: id }
    expect(:get => "/organizations/#{id}/media_export").to route_to(route)
  end

  it 'has a media_download_counts route' do
    route = { controller: 'morphosource/collections/organization_collections', action: 'media_download_counts_with_intersections_facet', id: id }
    expect(:get => "/organizations/#{id}/media_download_counts").to route_to(route)
  end

  it 'has a specimens objects_export route' do
    route = { controller: 'morphosource/collections/organization_collections/physical_objects/biological_specimens', action: 'objects_export', id: id }
    expect(:get => "/organizations/#{id}/biological_specimens/objects_export").to route_to(route)
  end

  it 'has a chos objects_export route' do
    route = { controller: 'morphosource/collections/organization_collections/physical_objects/cultural_heritage_objects', action: 'objects_export', id: id }
    expect(:get => "/organizations/#{id}/cultural_heritage_objects/objects_export").to route_to(route)
  end

  it 'has a devices_export route' do
    route = { controller: 'morphosource/collections/organization_collections/devices', action: 'devices_export', id: id }
    expect(:get => "/organizations/#{id}/devices/devices_export").to route_to(route)
  end
end
