require 'rails_helper'

RSpec.describe 'cart items routing', type: :routing do

  # cart items

  it 'has a route to add a work to the media cart' do
    route = { controller: 'morphosource/my/cart_items', action: 'create' }
    expect(:post => 'add_to_cart').to route_to(route)
  end

  # media cart

  it 'has a route for my media cart page' do
    route = { controller: 'morphosource/my/media_carts', action: 'index' }
    expect(:get => 'dashboard/my/cart').to route_to(route)
  end

  it 'has a route to remove an item from the media cart' do
    route = { controller: 'morphosource/my/media_carts', action: 'destroy' }
    expect(:delete => 'remove_from_cart').to route_to(route)
  end

  it 'has a route to download cart items' do
    route = { controller: 'morphosource/my/media_carts', action: 'download' }
    expect(:get => 'download_items').to route_to(route)
  end

  # downloads

  it 'has a route for my downloads page' do
    route = { controller: 'morphosource/my/downloads', action: 'index' }
    expect(:get => 'dashboard/my/downloads').to route_to(route)
  end

  it 'has a route to copy items from the downloads page to the shopping cart' do
    route = { controller: 'morphosource/my/downloads', action: 'batch_create' }
    expect(:post => 'batch_create_items').to route_to(route)
  end

  # requests

  it 'has a route for the my requests page' do
    route = { controller: 'morphosource/my/requests', action: 'index' }
    expect(:get => 'dashboard/my/requests').to route_to(route)
  end

  it 'has a route to request an item' do
    route = { controller: 'morphosource/my/requests', action: 'request_item' }
    expect(:put => 'request_item').to route_to(route)
  end

  it 'has a route to request an item again' do
    route = { controller: 'morphosource/my/requests', action: 'request_again' }
    expect(:get => 'request_again').to route_to(route)
  end

  it 'has a route to cancel a request' do
    route = { controller: 'morphosource/my/requests', action: 'cancel_request' }
    expect(:put => 'cancel_request').to route_to(route)
  end

  it 'has a route to request download from the work page' do
    route = { controller: 'morphosource/my/requests', action: 'request_work' }
    expect(:post => 'request_work').to route_to(route)
  end

  # request manager

  it 'has a route for the request manager page' do
    route = { controller: 'morphosource/my/request_managers', action: 'index' }
    expect(:get => 'dashboard/my/request_manager').to route_to(route)
  end

  it 'has a route to approve a download request' do
    route = { controller: 'morphosource/my/request_managers', action: 'approve_download' }
    expect(:put => 'approve_download').to route_to(route)
  end

  it 'has a route to clear a download request' do
    route = { controller: 'morphosource/my/request_managers', action: 'clear_request' }
    expect(:put => 'clear_request').to route_to(route)
  end

  it 'has a route to deny a download request' do
    route = { controller: 'morphosource/my/request_managers', action: 'deny_download' }
    expect(:put => 'deny_download').to route_to(route)
  end
end
