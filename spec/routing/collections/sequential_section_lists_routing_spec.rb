require 'rails_helper'

RSpec.describe 'collections routing', type: :routing do

  let(:id)            { '12345' }
  let(:collection_id) { 'abcde' }
  let(:media_id)      { 'fghij' }

  # my

  it 'has a my sequential section lists route' do
    route = { controller: 'morphosource/my/collections/media_lists/sequential_section_lists', action: 'index' }
    expect(:get => "/dashboard/my/sequential-section-lists").to route_to(route)
  end

  it 'has a create sequential section list route' do
    route = { controller: 'morphosource/my/collections/media_lists/sequential_section_lists', action: 'create' }
    expect(:post => "/dashboard/my/sequential-section-lists").to route_to(route)
  end

  it 'has a facet route' do
    route = { controller: 'morphosource/my/collections/media_lists/sequential_section_lists', action: 'facet', id: id }
    expect(:get => "/dashboard/my/sequential-section-lists/facet/#{id}").to route_to(route)
  end

  # dashboard

  it 'has a new sequential section list route' do
    route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'new' }
    expect(:get => "/dashboard/sequential-section-lists/new").to route_to(route)
  end

  it 'has a details route' do
    route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'edit', id: id }
    expect(:get => "/dashboard/sequential-section-lists/#{id}").to route_to(route)
  end

  it 'has a files route' do
    route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'files', id: id }
    expect(:get => "/dashboard/sequential-section-lists/#{id}/files").to route_to(route)
  end

  it 'has a members route' do
    route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'members', id: id }
    expect(:get => "/dashboard/sequential-section-lists/#{id}/members").to route_to(route)
  end

  it 'has a create sequential section list route' do
    route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'create' }
    expect(:post => "/dashboard/sequential-section-lists").to route_to(route)
  end

  it 'has an update sequential section list route without an id' do
    route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'update' }
    expect(:put => "/dashboard/sequential-section-lists").to route_to(route)
  end

  it 'has an update sequential section list route with put' do
    route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'update', id: id }
    expect(:put => "/dashboard/sequential-section-lists/#{id}").to route_to(route)
  end

  it 'has an update sequential section list route with patch' do
    route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'update', id: id }
    expect(:patch => "/dashboard/sequential-section-lists/#{id}").to route_to(route)
  end

  # general

  it 'has a sequential section lists route' do
    route = { controller: 'morphosource/collections/media_lists/sequential_section_lists', action: 'show', id: id }
    expect(:get => "/sequential-section-lists/#{id}").to route_to(route)
  end

  it 'has a sequential section lists specimens route' do
    route = { controller: 'morphosource/collections/biological_specimens', action: 'show', id: id }
    expect(:get => "/sequential-section-lists/#{id}/biological-specimens").to route_to(route)
  end

  it 'has a sequential section lists chos route' do
    route = { controller: 'morphosource/collections/cultural_heritage_objects', action: 'show', id: id }
    expect(:get => "/sequential-section-lists/#{id}/cultural-heritage-objects").to route_to(route)
  end

  it 'has a sequential section lists about route' do
    route = { controller: 'morphosource/collections/media_lists/sequential_section_lists', action: 'about', id: id }
    expect(:get => "/sequential-section-lists/#{id}/about").to route_to(route)
  end

  it 'has a sequential section lists media faceting route' do
    route = { controller: 'morphosource/collections/media_lists/sequential_section_lists', action: 'facet', id: id, collection_id: collection_id }
    expect(:get => "/sequential-section-lists/#{collection_id}/facet/#{id}").to route_to(route)
  end

  it 'has a sequential section lists specimens faceting route' do
    route = { controller: 'morphosource/collections/biological_specimens', action: 'facet', id: id, collection_id: collection_id }
    expect(:get => "/sequential-section-lists/#{collection_id}/biological-specimens/facet/#{id}").to route_to(route)
  end

  it 'has a sequential section lists chos faceting route' do
    route = { controller: 'morphosource/collections/cultural_heritage_objects', action: 'facet', id: id, collection_id: collection_id }
    expect(:get => "/sequential-section-lists/#{collection_id}/cultural-heritage-objects/facet/#{id}").to route_to(route)
  end

  it 'has a sequential section lists order media route' do
    route = { controller: 'morphosource/collections/media_lists/sequential_section_lists', action: 'order_media', id: id }
    expect(:get => "/sequential-section-lists/#{id}/order-media").to route_to(route)
  end

  it 'has a media lists preview media route' do
    route = { controller: 'morphosource/collections/media_lists/sequential_section_lists', action: 'preview', id: id, media_id: media_id }
    expect(:get => "/sequential-section-lists/#{id}/preview/#{media_id}").to route_to(route)
  end

  # CSV exports

  it 'has a media_downloads route' do
    route = { controller: 'morphosource/collections', action: 'media_downloads', id: id }
    expect(:get => "/sequential-section-lists/#{id}/media-downloads").to route_to(route)
  end

  it 'has a media_requests route' do
    route = { controller: 'morphosource/collections', action: 'media_requests', id: id }
    expect(:get => "/sequential-section-lists/#{id}/media-requests").to route_to(route)
  end

  it 'has a media_export route' do
    route = { controller: 'morphosource/collections/media_lists/sequential_section_lists', action: 'media_export_with_intersections_facet', id: id }
    expect(:get => "/sequential-section-lists/#{id}/media-export").to route_to(route)
  end

  it 'has a media_download_counts route' do
    route = { controller: 'morphosource/collections/media_lists/sequential_section_lists', action: 'media_download_counts_with_intersections_facet', id: id }
    expect(:get => "/sequential-section-lists/#{id}/media-download-counts").to route_to(route)
  end

  it 'has a specimens objects_export route' do
    route = { controller: 'morphosource/collections/biological_specimens', action: 'objects_export', id: id }
    expect(:get => "/sequential-section-lists/#{id}/biological-specimens/objects-export").to route_to(route)
  end

  it 'has a chos objects_export route' do
    route = { controller: 'morphosource/collections/cultural_heritage_objects', action: 'objects_export', id: id }
    expect(:get => "/sequential-section-lists/#{id}/cultural-heritage-objects/objects-export").to route_to(route)
  end
end

RSpec.describe 'sequential_section_list redirects', type: :request do

  let(:id)  { '12345' }

  it 'redirects sequential_section_lists/:id' do
    get "/sequential_section_lists/#{id}"
    expect(response).to redirect_to(sequential_section_list_path(id))
  end

  it 'redirects sequential_section_lists/:id/biological_specimens' do
    get "/sequential_section_lists/#{id}/biological_specimens"
    expect(response).to redirect_to(sequential_section_list_specimens_path(id))
  end

  it 'redirects sequential_section_lists/:id/cultural_heritage_objects' do
    get "/sequential_section_lists/#{id}/cultural_heritage_objects"
    expect(response).to redirect_to(sequential_section_list_chos_path(id))
  end

  it 'redirects sequential_section_lists/:id/about' do
    get "/sequential_section_lists/#{id}/about"
    expect(response).to redirect_to(sequential_section_list_about_path(id))
  end
end