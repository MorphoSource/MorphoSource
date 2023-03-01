require 'rails_helper'

RSpec.describe 'collections routing', type: :routing do

  let(:id)            { '12345' }
  let(:collection_id) { 'abcde' }

  # my
  it 'has a my media lists route' do
    route = { controller: 'morphosource/my/collections/media_lists', action: 'index' }
    expect(:get => "/dashboard/my/media_lists").to route_to(route)
  end

  it 'has a my sequential section lists lists route' do
    route = { controller: 'morphosource/my/collections/media_lists/sequential_section_lists', action: 'index' }
    expect(:get => "/dashboard/my/sequential_section_lists").to route_to(route)
  end

  it 'has a search my collections route' do
    route = { controller: 'morphosource/my/collections/search_collections', action: 'search' }
    expect(:get => "/my/collections/search").to route_to(route)
  end

  # collections
  # this will be redirected by the controller to either teams or projects
  it 'has a collections show route' do
    route = { controller: 'morphosource/collections', action: 'show', id: id }
    expect(:get => "/collections/#{id}").to route_to(route)
  end

  # teams
  it 'has a teams route' do
    route = { controller: 'morphosource/collections/teams', action: 'show', id: id }
    expect(:get => "/teams/#{id}").to route_to(route)
  end

  it 'has a teams specimens route' do
    route = { controller: 'morphosource/collections/biological_specimens', action: 'show', id: id }
    expect(:get => "/teams/#{id}/biological_specimens").to route_to(route)
  end

  it 'has a teams chos route' do
    route = { controller: 'morphosource/collections/cultural_heritage_objects', action: 'show', id: id }
    expect(:get => "/teams/#{id}/cultural_heritage_objects").to route_to(route)
  end

  it 'has a teams about route' do
    route = { controller: 'morphosource/collections/teams', action: 'about', id: id }
    expect(:get => "/teams/#{id}/about").to route_to(route)
  end

  # projects
  it 'has a projects route' do
    route = { controller: 'morphosource/collections/projects', action: 'show', id: id }
    expect(:get => "/projects/#{id}").to route_to(route)
  end

  it 'has a projects specimens route' do
    route = { controller: 'morphosource/collections/biological_specimens', action: 'show', id: id }
    expect(:get => "/projects/#{id}/biological_specimens").to route_to(route)
  end

  it 'has a projects chos route' do
    route = { controller: 'morphosource/collections/cultural_heritage_objects', action: 'show', id: id }
    expect(:get => "/projects/#{id}/cultural_heritage_objects").to route_to(route)
  end

  it 'has a projects about route' do
    route = { controller: 'morphosource/collections/projects', action: 'about', id: id }
    expect(:get => "/projects/#{id}/about").to route_to(route)
  end

  # media_lists
  it 'has a media lists route' do
    route = { controller: 'morphosource/collections/media_lists', action: 'show', id: id }
    expect(:get => "/media_lists/#{id}").to route_to(route)
  end

  it 'has a media lists specimens route' do
    route = { controller: 'morphosource/collections/biological_specimens', action: 'show', id: id }
    expect(:get => "/media_lists/#{id}/biological_specimens").to route_to(route)
  end

  it 'has a media lists chos route' do
    route = { controller: 'morphosource/collections/cultural_heritage_objects', action: 'show', id: id }
    expect(:get => "/media_lists/#{id}/cultural_heritage_objects").to route_to(route)
  end

  it 'has a media lists about route' do
    route = { controller: 'morphosource/collections/media_lists', action: 'about', id: id }
    expect(:get => "/media_lists/#{id}/about").to route_to(route)
  end

  it 'has a media lists media faceting route' do
    route = { controller: 'morphosource/collections/media_lists', action: 'facet', id: id, collection_id: collection_id }
    expect(:get => "/media_lists/#{collection_id}/facet/#{id}").to route_to(route)
  end

  it 'has a media lists specimens faceting route' do
    route = { controller: 'morphosource/collections/biological_specimens', action: 'facet', id: id, collection_id: collection_id }
    expect(:get => "/media_lists/#{collection_id}/biological_specimens/facet/#{id}").to route_to(route)
  end

  it 'has a media lists chos faceting route' do
    route = { controller: 'morphosource/collections/cultural_heritage_objects', action: 'facet', id: id, collection_id: collection_id }
    expect(:get => "/media_lists/#{collection_id}/cultural_heritage_objects/facet/#{id}").to route_to(route)
  end

  it 'has a media lists order media route' do
    route = { controller: 'morphosource/collections/media_lists', action: 'order_media', id: id }
    expect(:get => "/media_lists/#{id}/order_media").to route_to(route)
  end


  # sequential_section_lists
  it 'has a sequential section lists route' do
    route = { controller: 'morphosource/collections/media_lists/sequential_section_lists', action: 'show', id: id }
    expect(:get => "/sequential_section_lists/#{id}").to route_to(route)
  end

  it 'has a sequential section lists specimens route' do
    route = { controller: 'morphosource/collections/biological_specimens', action: 'show', id: id }
    expect(:get => "/sequential_section_lists/#{id}/biological_specimens").to route_to(route)
  end

  it 'has a sequential section lists chos route' do
    route = { controller: 'morphosource/collections/cultural_heritage_objects', action: 'show', id: id }
    expect(:get => "/sequential_section_lists/#{id}/cultural_heritage_objects").to route_to(route)
  end

  it 'has a sequential section lists about route' do
    route = { controller: 'morphosource/collections/media_lists/sequential_section_lists', action: 'about', id: id }
    expect(:get => "/sequential_section_lists/#{id}/about").to route_to(route)
  end

  it 'has a sequential section lists media faceting route' do
    route = { controller: 'morphosource/collections/media_lists/sequential_section_lists', action: 'facet', id: id, collection_id: collection_id }
    expect(:get => "/sequential_section_lists/#{collection_id}/facet/#{id}").to route_to(route)
  end

  it 'has a sequential section lists specimens faceting route' do
    route = { controller: 'morphosource/collections/biological_specimens', action: 'facet', id: id, collection_id: collection_id }
    expect(:get => "/sequential_section_lists/#{collection_id}/biological_specimens/facet/#{id}").to route_to(route)
  end

  it 'has a sequential section lists chos faceting route' do
    route = { controller: 'morphosource/collections/cultural_heritage_objects', action: 'facet', id: id, collection_id: collection_id }
    expect(:get => "/sequential_section_lists/#{collection_id}/cultural_heritage_objects/facet/#{id}").to route_to(route)
  end

  it 'has a sequential section lists order media route' do
    route = { controller: 'morphosource/collections/media_lists/sequential_section_lists', action: 'order_media', id: id }
    expect(:get => "/sequential_section_lists/#{id}/order_media").to route_to(route)
  end
end

RSpec.describe 'collections dashboard routes', type: :routing do
  let(:id)  { '123' }

  describe 'collections' do
    it 'has an update route' do
      route = { controller: 'morphosource/dashboard/collections', action: 'update', id: id }
      expect(:put => "/dashboard/collections/#{id}").to route_to(route)
      expect(:patch => "/dashboard/collections/#{id}").to route_to(route)
    end
    it 'has an edit route' do
      route = { controller: 'morphosource/dashboard/collections', action: 'edit', id: id }
      expect(:get => "/dashboard/collections/#{id}").to route_to(route)
      expect(:get => "/dashboard/collections/#{id}/edit").to route_to(route)
    end
    it 'has a create subcollection route' do
      route = { controller: 'morphosource/dashboard/nest_collections', action: 'create_collection_under', parent_id: id }
      expect(:get => "/collections/#{id}/under").to route_to(route)
    end
  end

  # teams
  describe 'teams' do
    it 'has a details edit route' do
      route = { controller: 'morphosource/dashboard/collections/teams', action: 'edit', id: id }
      expect(:get => "/dashboard/teams/#{id}").to route_to(route)
    end
    it 'has a members edit route' do
      route = { controller: 'morphosource/dashboard/collections/teams', action: 'members', id: id }
      expect(:get => "/dashboard/teams/#{id}/members").to route_to(route)
    end
    it 'has an organization edit route' do
      route = { controller: 'morphosource/dashboard/collections/teams', action: 'organization', id: id }
      expect(:get => "/dashboard/teams/#{id}/organization").to route_to(route)
    end
    it 'has a projects edit route' do
      route = { controller: 'morphosource/dashboard/collections/teams', action: 'projects', id: id }
      expect(:get => "/dashboard/teams/#{id}/projects").to route_to(route)
    end
    it 'has a new team route' do
      route = { controller: 'morphosource/dashboard/collections/teams', action: 'new' }
      expect(:get => "/dashboard/teams/new").to route_to(route)
    end
    it 'has a create team route' do
      route = { controller: 'morphosource/dashboard/collections/teams', action: 'create' }
      expect(:post => "/dashboard/teams").to route_to(route)
    end
    it 'has an update team route' do
      route = { controller: 'morphosource/dashboard/collections/teams', action: 'update' }
      expect(:put => "/dashboard/teams").to route_to(route)
    end
    it 'has an update team route' do
      route = { controller: 'morphosource/dashboard/collections/teams', action: 'update', id: id }
      expect(:put => "/dashboard/teams/#{id}").to route_to(route)
    end
    it 'has an update team route' do
      route = { controller: 'morphosource/dashboard/collections/teams', action: 'update', id: id }
      expect(:patch => "/dashboard/teams/#{id}").to route_to(route)
    end
    it 'has a files route' do
      route = { controller: 'morphosource/dashboard/collections/teams', action: 'files', id: id }
      expect(:get => "/dashboard/teams/#{id}/files").to route_to(route)
    end
  end

  # projects
  describe 'projects' do
    it 'has a details route' do
      route = { controller: 'morphosource/dashboard/collections/projects', action: 'edit', id: id }
      expect(:get => "/dashboard/projects/#{id}").to route_to(route)
    end
    it 'has a members route' do
      route = { controller: 'morphosource/dashboard/collections/projects', action: 'members', id: id }
      expect(:get => "/dashboard/projects/#{id}/members").to route_to(route)
    end
    it 'has a new project route' do
      route = { controller: 'morphosource/dashboard/collections/projects', action: 'new' }
      expect(:get => "/dashboard/projects/new").to route_to(route)
    end
    it 'has a create project route' do
      route = { controller: 'morphosource/dashboard/collections/projects', action: 'create' }
      expect(:post => "/dashboard/projects").to route_to(route)
    end
    it 'has an update project route' do
      route = { controller: 'morphosource/dashboard/collections/projects', action: 'update' }
      expect(:put => "/dashboard/projects").to route_to(route)
    end
    it 'has an update project route' do
      route = { controller: 'morphosource/dashboard/collections/projects', action: 'update', id: id }
      expect(:put => "/dashboard/projects/#{id}").to route_to(route)
    end
    it 'has an update project route' do
      route = { controller: 'morphosource/dashboard/collections/projects', action: 'update', id: id }
      expect(:patch => "/dashboard/projects/#{id}").to route_to(route)
    end
    it 'has a files route' do
      route = { controller: 'morphosource/dashboard/collections/projects', action: 'files', id: id }
      expect(:get => "/dashboard/projects/#{id}/files").to route_to(route)
    end
  end

  # media lists
  describe 'media lists' do
    it 'has a details route' do
      route = { controller: 'morphosource/dashboard/collections/media_lists', action: 'edit', id: id }
      expect(:get => "/dashboard/media_lists/#{id}").to route_to(route)
    end
    it 'has a members route' do
      route = { controller: 'morphosource/dashboard/collections/media_lists', action: 'members', id: id }
      expect(:get => "/dashboard/media_lists/#{id}/members").to route_to(route)
    end
    it 'has a new media list route' do
      route = { controller: 'morphosource/dashboard/collections/media_lists', action: 'new' }
      expect(:get => "/dashboard/media_lists/new").to route_to(route)
    end
    it 'has a create media list route' do
      route = { controller: 'morphosource/dashboard/collections/media_lists', action: 'create' }
      expect(:post => "/dashboard/media_lists").to route_to(route)
    end
    it 'has an update media list route without an id' do
      route = { controller: 'morphosource/dashboard/collections/media_lists', action: 'update' }
      expect(:put => "/dashboard/media_lists").to route_to(route)
    end
    it 'has an update media list route with put' do
      route = { controller: 'morphosource/dashboard/collections/media_lists', action: 'update', id: id }
      expect(:put => "/dashboard/media_lists/#{id}").to route_to(route)
    end
    it 'has an update media list route with patch' do
      route = { controller: 'morphosource/dashboard/collections/media_lists', action: 'update', id: id }
      expect(:patch => "/dashboard/media_lists/#{id}").to route_to(route)
    end
    it 'has a files route' do
      route = { controller: 'morphosource/dashboard/collections/media_lists', action: 'files', id: id }
      expect(:get => "/dashboard/media_lists/#{id}/files").to route_to(route)
    end
  end

  # sequential section lists
  describe 'sequential section lists' do
    it 'has a details route' do
      route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'edit', id: id }
      expect(:get => "/dashboard/sequential_section_lists/#{id}").to route_to(route)
    end
    it 'has a members route' do
      route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'members', id: id }
      expect(:get => "/dashboard/sequential_section_lists/#{id}/members").to route_to(route)
    end
    it 'has a new sequential section list route' do
      route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'new' }
      expect(:get => "/dashboard/sequential_section_lists/new").to route_to(route)
    end
    it 'has a create sequential section list route' do
      route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'create' }
      expect(:post => "/dashboard/sequential_section_lists").to route_to(route)
    end
    it 'has an update sequential section list route' do
      route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'update' }
      expect(:put => "/dashboard/sequential_section_lists").to route_to(route)
    end
    it 'has an update sequential section list route' do
      route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'update', id: id }
      expect(:put => "/dashboard/sequential_section_lists/#{id}").to route_to(route)
    end
    it 'has an update sequential section list route' do
      route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'update', id: id }
      expect(:patch => "/dashboard/sequential_section_lists/#{id}").to route_to(route)
    end
    it 'has a files route' do
      route = { controller: 'morphosource/dashboard/collections/media_lists/sequential_section_lists', action: 'files', id: id }
      expect(:get => "/dashboard/sequential_section_lists/#{id}/files").to route_to(route)
    end
  end
end

RSpec.describe 'collections redirects', type: :request do

  let(:id)  { '12345' }

  # teams
  it 'redirects teams/specimens/:id' do
    route = { controller: 'morphosource/collections/biological_specimens', action: 'show', id: id }
    get "/teams/specimens/#{id}"
    expect(response).to redirect_to(team_specimens_path(id))
  end

  it 'redirects teams/chos/:id' do
    route = { controller: 'morphosource/collections/cultural_heritage_objects', action: 'show', id: id }
    get "/teams/chos/#{id}"
    expect(response).to redirect_to(team_chos_path(id))
  end

  # projects
  it 'redirects projects/specimens/:id' do
    route = { controller: 'morphosource/collections/biological_specimens', action: 'show', id: id }
    get "/projects/specimens/#{id}"
    expect(response).to redirect_to(project_specimens_path(id))
  end

  it 'redirects projects/chos/:id' do
    route = { controller: 'morphosource/collections/cultural_heritage_objects', action: 'show', id: id }
    get "/projects/chos/#{id}"
    expect(response).to redirect_to(project_chos_path(id))
  end
end

RSpec.describe 'csv exports', type: :routing do

  let(:id)  { '12345' }

  # media_lists
  it 'has a media_downloads route' do
    route = { controller: 'morphosource/collections', action: 'media_downloads', id: id }
    expect(:get => "/media_lists/#{id}/media_downloads").to route_to(route)
  end

  it 'has a media_requests route' do
    route = { controller: 'morphosource/collections', action: 'media_requests', id: id }
    expect(:get => "/media_lists/#{id}/media_requests").to route_to(route)
  end

  it 'has a media_export route' do
    route = { controller: 'morphosource/collections/media_lists', action: 'media_export_with_intersections_facet', id: id }
    expect(:get => "/media_lists/#{id}/media_export").to route_to(route)
  end

  it 'has a media_download_counts route' do
    route = { controller: 'morphosource/collections/media_lists', action: 'media_download_counts_with_intersections_facet', id: id }
    expect(:get => "/media_lists/#{id}/media_download_counts").to route_to(route)
  end

  it 'has a specimens objects_export route' do
    route = { controller: 'morphosource/collections/biological_specimens', action: 'objects_export', id: id }
    expect(:get => "/media_lists/#{id}/biological_specimens/objects_export").to route_to(route)
  end

  it 'has a chos objects_export route' do
    route = { controller: 'morphosource/collections/cultural_heritage_objects', action: 'objects_export', id: id }
    expect(:get => "/media_lists/#{id}/cultural_heritage_objects/objects_export").to route_to(route)
  end

  # sequential_section_lists
  it 'has a media_downloads route' do
    route = { controller: 'morphosource/collections', action: 'media_downloads', id: id }
    expect(:get => "/sequential_section_lists/#{id}/media_downloads").to route_to(route)
  end

  it 'has a media_requests route' do
    route = { controller: 'morphosource/collections', action: 'media_requests', id: id }
    expect(:get => "/sequential_section_lists/#{id}/media_requests").to route_to(route)
  end

  it 'has a media_export route' do
    route = { controller: 'morphosource/collections/media_lists/sequential_section_lists', action: 'media_export_with_intersections_facet', id: id }
    expect(:get => "/sequential_section_lists/#{id}/media_export").to route_to(route)
  end

  it 'has a media_download_counts route' do
    route = { controller: 'morphosource/collections/media_lists/sequential_section_lists', action: 'media_download_counts_with_intersections_facet', id: id }
    expect(:get => "/sequential_section_lists/#{id}/media_download_counts").to route_to(route)
  end

  it 'has a specimens objects_export route' do
    route = { controller: 'morphosource/collections/biological_specimens', action: 'objects_export', id: id }
    expect(:get => "/sequential_section_lists/#{id}/biological_specimens/objects_export").to route_to(route)
  end

  it 'has a chos objects_export route' do
    route = { controller: 'morphosource/collections/cultural_heritage_objects', action: 'objects_export', id: id }
    expect(:get => "/sequential_section_lists/#{id}/cultural_heritage_objects/objects_export").to route_to(route)
  end


end
