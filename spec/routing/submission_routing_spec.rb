require 'rails_helper'

RSpec.describe 'submission routing', type: :routing do

  it 'has a new route' do
    route = { controller: 'submissions', action: 'new' }
    expect(:get => '/submissions/new').to route_to(route)
    expect(:get => new_submission_path).to route_to(route)
  end

  it 'has a route for search PO ajax' do
    route = { controller: 'submissions', action: 'search_po_ajax' }
    expect(:post => '/submissions/search_po_ajax').to route_to(route)
  end

  it 'has a route for save data' do
    route = { controller: 'submissions', action: 'save_data' }
    expect(:post => '/submissions/save_data').to route_to(route)
  end

  it 'has a route for organization default media fields' do
    route = { controller: 'submissions', action: 'organization_default_media_fields' }
    expect(:get => '/submissions/organization_default_media_fields').to route_to(route)
  end

end
