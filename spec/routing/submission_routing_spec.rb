require 'rails_helper'

RSpec.describe 'submission routing', type: :routing do

  it 'has a new route' do
    route = { controller: 'submissions', action: 'new' }
    expect(:get => '/submissions/new').to route_to(route)
    expect(:get => new_submission_path).to route_to(route)
  end

end
