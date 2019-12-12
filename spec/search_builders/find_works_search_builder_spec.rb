require 'rails_helper'

RSpec.describe FindWorksSearchBuilder do

  subject { described_class.new(context) }

  let(:context) { double(params: params) }

  describe 'depositor filter' do
    it 'does not limit the search to works deposited by current user' do
      expect(described_class.default_processor_chain).to_not include(:show_only_resources_deposited_by_current_user)
    end
  end

  describe 'type filter' do
    describe 'no types specified in request parameters' do
      let(:params) { { id: 'test', q: 'abc' } }
      it 'allows all work types' do
        expect(subject.models).to match_array(Hyrax.config.curation_concerns)
      end
    end
    describe 'type(s) specified in request parameters' do
      let(:params) { { id: 'test', q: 'abc', type: types } }
      let(:types) { [ 'BiologicalSpecimen', 'CulturalHeritageObject' ] }
      it 'allows only the specified work types' do
        expect(subject.models).to match_array(types.map(&:constantize))
      end
    end
  end

end
