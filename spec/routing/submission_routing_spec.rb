require 'rails_helper'

RSpec.describe 'submission routing', type: :routing do

  it 'has a new route' do
    route = { controller: 'submissions', action: 'new' }
    expect(:get => '/submissions/new').to route_to(route)
    expect(:get => new_submission_path).to route_to(route)
  end

  it 'has a route for new organization submit' do
    route = { controller: 'submissions', action: 'new_organization_submit' }
    expect(:post => '/submissions/new_organization_submit').to route_to(route)
  end

  it 'has a route for new taxonomy submit' do
    route = { controller: 'submissions', action: 'new_taxonomy_submit' }
    expect(:post => '/submissions/new_taxonomy_submit').to route_to(route)
  end

end
