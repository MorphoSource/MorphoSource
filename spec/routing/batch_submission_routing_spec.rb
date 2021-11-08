require 'rails_helper'

RSpec.describe 'batch_submission routing', type: :routing do

  it 'has a new route' do
    route = { controller: 'batch_submissions', action: 'new' }
    expect(:get => '/batch_submissions/new').to route_to(route)
    expect(:get => new_batch_submission_path).to route_to(route)
  end

end
