require 'rails_helper'

RSpec.describe Morphosource::IDigBioSearchController, type: :controller do

  describe '#search_idigbio_by_occurrence_id_ajax' do

		let(:params) { {:oid => 'MCZ:Mamm:44858'} }

		before do
			allow(controller).to receive(:params).and_return(params)
		end

    it 'returns JSON response' do
      get :search_idigbio_by_occurrence_id_ajax, params: params
      expect(JSON.parse(response.body)).to include_json(
        occurrence_id: params[:oid]
      )
    end

	end

end
