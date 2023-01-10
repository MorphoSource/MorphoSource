require 'rails_helper'

RSpec.describe 'remote_file_submitter routing', type: :routing do

  it 'has a route to grant remote_file_submitter status' do
    route = { controller: 'remote_file_submitters', action: 'make_remote_file_submitter', id: 'abc'}
    expect(:post => 'users/abc/make_remote_file_submitter').to route_to(route)
  end

  it 'has a route to remove remote_file_submitter status' do
    route = { controller: 'remote_file_submitters', action: 'remove_remote_file_submitter', id: 'abc'}
    expect(:post => 'users/abc/remove_remote_file_submitter').to route_to(route)
  end
end
