require 'rails_helper'

RSpec.describe 'globus_file_submitter routing', type: :routing do

  it 'has a route to grant globus_file_submitter status' do
    route = { controller: 'globus_file_submitters', action: 'make_globus_file_submitter', id: 'abc'}
    expect(:post => 'users/abc/make_globus_file_submitter').to route_to(route)
  end

  it 'has a route to remove globus_file_submitter status' do
    route = { controller: 'globus_file_submitters', action: 'remove_globus_file_submitter', id: 'abc'}
    expect(:post => 'users/abc/remove_globus_file_submitter').to route_to(route)
  end
end
