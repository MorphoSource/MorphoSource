require 'rails_helper'

RSpec.describe 'MS1 page routing', type: :routing do

  it 'has a route for SpecimenDetail' do
    route = { controller: 'morphosource/ms1', action: 'biological_specimens', id: '12345'}
    expect(:get => 'Detail/SpecimenDetail/Show/specimen_id/12345').to route_to(route)
    expect(:get => 'index.php/Detail/SpecimenDetail/Show/specimen_id/12345').to route_to(route)
  end

  it 'has a route for ProjectDetail' do
    route = { controller: 'morphosource/ms1', action: 'projects', id: '12345'}
    expect(:get => 'Detail/ProjectDetail/Show/project_id/12345').to route_to(route)
    expect(:get => 'index.php/Detail/ProjectDetail/Show/project_id/12345').to route_to(route)
  end

  it 'has a route for media_file_id' do
    route = { controller: 'morphosource/ms1', action: 'media', id: '12345'}
    expect(:get => 'Detail/MediaDetail/Show/media_file_id/12345').to route_to(route)
    expect(:get => 'index.php/Detail/MediaDetail/Show/media_file_id/12345').to route_to(route)
  end

  it 'has a route for Media group' do
    route = { controller: 'morphosource/ms1', action: 'media_group', id: '12345'}
    expect(:get => 'Detail/MediaDetail/Show/media_id/12345').to route_to(route)
    expect(:get => 'index.php/Detail/MediaDetail/Show/media_id/12345').to route_to(route)
  end

end
