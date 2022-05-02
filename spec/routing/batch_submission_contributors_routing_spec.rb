require 'rails_helper'

RSpec.describe 'batch_submission_contributor routing', type: :routing do

  it 'has a route to grant batch_submission_contributor status' do
    route = { controller: 'batch_submission_contributors', action: 'make_batch_submission_contributor', id: 'abc'}
    expect(:post => 'users/abc/make_batch_submission_contributor').to route_to(route)
  end

  it 'has a route to remove batch_submission_contributor status' do
    route = { controller: 'batch_submission_contributors', action: 'remove_batch_submission_contributor', id: 'abc'}
    expect(:post => 'users/abc/remove_batch_submission_contributor').to route_to(route)
  end
end
