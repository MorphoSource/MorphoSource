require 'rails_helper'

RSpec.describe 'Media Cart API routing', type: :routing do
  it 'routes GET /api/media-cart to the media cart API controller' do
    expect(get: '/api/media-cart').to route_to(
      controller: 'morphosource/api/media_cart', action: 'index', format: 'json'
    )
  end

  it 'has a named route helper' do
    expect(Rails.application.routes.url_helpers.api_media_cart_path).to eq('/api/media-cart')
  end
end
