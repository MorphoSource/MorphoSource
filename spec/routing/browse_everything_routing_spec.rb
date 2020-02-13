require 'rails_helper'

RSpec.describe 'Check if BrowseEverything is setup in the routes config', type: :routing do
  routes { BrowseEverything::Engine.routes }
  it "routes to an action" do
    expect(get: '/connect').to route_to(controller: 'browse_everything', action: 'auth')
  end
end

