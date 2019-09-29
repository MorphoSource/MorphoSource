require 'rails_helper'

RSpec.describe 'BSO page routing', type: :routing do

  it 'has a route BSO edit page' do
    route = { controller: 'hyrax/biological_specimens', action: 'edit', id: 'foobar'}
    expect(:get => 'concern/biological_specimens/foobar/edit').to route_to(route)
  end

end
