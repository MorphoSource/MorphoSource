require 'rails_helper'

RSpec.describe 'zip routing', type: :routing do

  it 'has a new route' do
    route = { controller: 'morphosource/zip_media', action: 'zip' }
    expect(:get => '/zip').to route_to(route)
  end

end
