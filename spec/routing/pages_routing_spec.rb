require 'rails_helper'

RSpec.describe 'pages routing', type: :routing do
  {
    '/about' => 'about-morphosource',
    '/mission' => 'our-mission',
    '/terms' => 'terms',
    '/contributor-terms' => 'contributor-terms'
  }.each do |path, slug|
    it "routes #{path} to pages#show with slug #{slug}" do
      expect(get: path).to route_to(controller: 'pages', action: 'show', slug: slug)
    end
  end
end
