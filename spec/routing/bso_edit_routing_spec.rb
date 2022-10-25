require 'rails_helper'

RSpec.describe 'BSO page routing', type: :routing do

  it 'has a route BSO edit page' do
    route = { controller: 'hyrax/biological_specimens', action: 'edit', id: 'foobar'}
    expect(:get => 'concern/biological_specimens/foobar/edit').to route_to(route)
  end

  it 'has a route search_idigbio_by_occurrence_id_ajax' do
    route = { controller: 'morphosource/i_dig_bio_search', action: 'search_idigbio_by_occurrence_id_ajax'}
    expect(:post => 'search_idigbio_by_occurrence_id_ajax').to route_to(route)
  end

end
