require 'rails_helper'

RSpec.describe Morphosource::UserWorksAccessSearchService do

  subject { described_class.new(scope) }

  let(:user)   { User.create(email:'registered@email.com', password: 'password') }

  let(:ability) { ::Ability.new(user) }
  let(:scope)   { double(blacklight_config: CatalogController.blacklight_config, current_ability: ability) }

  # let(:model) { BiologicalSpecimen }
  # let(:params) { {} }

  describe '.call' do
    it 'instantiates the search service and calls it' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call(scope: scope)
    end
  end

  describe '#call' do
    let!(:media)  { Media.create(title: ['media'], visibility: 'open') }

    describe 'no search params' do
      it 'returns SolrDocuments for all of the specified model' do
        results = subject.call
        expect(results).to match_array([ SolrDocument])
        expect(results.map(&:id)).to match_array([ media.id ])
      end
    end
  end

end
