require 'rails_helper'

RSpec.describe Hyrax::BrowseTeamsController, type: :controller do

  it 'allows non-logged in users to view' do
    get :index
    expect(response.status).to eq(200)
  end
end
