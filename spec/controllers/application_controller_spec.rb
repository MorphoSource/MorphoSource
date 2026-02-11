require 'rails_helper'

RSpec.describe ApplicationController, :type => :controller do

  describe '#sanitize_sort_parameters' do
    controller do
      def index
        head :ok
      end
    end

    before do
      routes.draw { get 'index' => 'anonymous#index' }
    end

    it 'allows valid sort parameters' do
      get :index, params: { sort: 'title_ssi asc' }
      expect(response).to have_http_status(:ok)
      expect(request.params[:sort]).to eq('title_ssi asc')
    end

    it 'removes invalid sort parameters' do
      expect(Rails.logger).to receive(:warn).with(/Dropping invalid sort param: "invalid_sort_param"/)
      get :index, params: { sort: 'invalid_sort_param' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#allowed_sort_parameters' do
    let(:allowed_sort_parameters) { controller.blacklight_config.sort_fields.keys }

    it 'returns an array of allowed sort parameters' do
      expect(controller.allowed_sort_parameters).to match_array(allowed_sort_parameters)
    end
  end
end