require 'rails_helper'

RSpec.describe 'tags routing', type: :routing do

  it 'has a new index route' do
    route = { controller: 'morphosource/tags', action: 'index' }
    expect(:get => '/tags').to route_to(route)
  end

  it 'has a new show route' do
    route = { controller: 'morphosource/tags', action: 'show', tag: 'tag' }
    expect(:get => '/tags/tag').to route_to(route)
  end

end
