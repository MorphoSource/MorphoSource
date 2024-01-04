require 'rails_helper'

RSpec.describe 'Media page routing', type: :routing do
  it 'has a route Media edit page' do
    route = { controller: 'hyrax/media', action: 'edit', id: 'foobar'}
    expect(:get => 'concern/media/foobar/edit').to route_to(route)
  end
end
