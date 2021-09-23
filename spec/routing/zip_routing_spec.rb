require 'rails_helper'

RSpec.describe 'zip routing', type: :routing do

  it 'has a post route to zip' do
    route = { controller: 'morphosource/zip_media', action: 'zip' }
    expect(:post => '/zip').to route_to(route)
  end

  it 'has a get route to cart_to_zip' do
    route = { controller: 'morphosource/zip_media', action: 'cart_to_zip' }
    expect(:get => '/zip').to route_to(route)
  end

end
