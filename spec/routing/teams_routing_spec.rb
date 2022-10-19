require 'rails_helper'

RSpec.describe 'teams/projects routing', type: :routing do

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

RSpec.describe 'teams/projects redirects', type: :request do

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
