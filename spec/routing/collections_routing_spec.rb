require 'rails_helper'

RSpec.describe 'collections routing', type: :routing do

  let(:id)  { '12345' }

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
