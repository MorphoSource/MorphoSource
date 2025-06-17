require 'rails_helper'

RSpec.describe 'docs routing', type: :routing do
  it 'routes /terms to pages#show with correct slug' do
    expect(get: '/terms').to route_to(
      controller: 'pages',
      action: 'show',
      slug: 'terms'
    )
  end
  
  it 'routes /contributor-terms to pages#show with correct slug' do
    expect(get: '/contributor-terms').to route_to(
      controller: 'pages',
      action: 'show',
      slug: 'contributor-terms'
    )
  end
end
