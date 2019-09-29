require 'rails_helper'

RSpec.describe 'submission routing', type: :routing do

  it 'has a new route' do
    route = { controller: 'submissions', action: 'new' }
    expect(:get => '/submissions/new').to route_to(route)
    expect(:get => new_submission_path).to route_to(route)
  end

  it 'has a route for new institution submit' do
    route = { controller: 'submissions', action: 'new_institution_submit' }
    expect(:post => '/submissions/new_institution_submit').to route_to(route)
  end

  it 'has a route for new taxonomy submit' do
    route = { controller: 'submissions', action: 'new_taxonomy_submit' }
    expect(:post => '/submissions/new_taxonomy_submit').to route_to(route)
  end

end
