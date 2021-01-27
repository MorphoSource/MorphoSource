require 'rails_helper'

RSpec.describe 'docs routing', type: :routing do

  it 'has a terms route' do
    route = { controller: 'docs', action: 'terms' }
    expect(:get => '/terms').to route_to(route)
  end

  it 'has a contributor terms route' do
    route = { controller: 'docs', action: 'contributor_terms' }
    expect(:get => '/contributor_terms').to route_to(route)
  end
end
