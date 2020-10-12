require 'rails_helper'

RSpec.describe Morphosource::Ms1Controller, type: :controller do

  scenario 'MS1 specimen detail should redirect to biological_specimens' do
    get :biological_specimens, params: { id: '1234' }
    expect(response).to redirect_to "/biological_specimens/0000S1234"
  end

  scenario 'MS1 media detail should redirect to media' do
    get :media, params: { id: '1234' }
    expect(response).to redirect_to "/media/000001234"
  end

  scenario 'MS1 project detail should redirect to projects' do
    get :projects, params: { id: '1234' }
    expect(response).to redirect_to "/projects/0000C1234"
  end

end
