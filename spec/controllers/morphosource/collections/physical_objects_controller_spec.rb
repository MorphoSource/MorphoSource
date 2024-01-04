require 'rails_helper'
require 'spec_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::Collections::PhysicalObjectsController, type: :controller do

  describe 'LinkedTeamsControllerBehavior' do
    it 'is included' do
      expect(described_class.ancestors).to include(Morphosource::Collections::LinkedTeamsControllerBehavior)
    end
  end

  describe "media_count_search_builder_class" do
    it{ expect(subject.media_count_search_builder_class).to eq( Morphosource::Collections::MediaSearchBuilder) }
  end

  describe 'get_object_ids' do
    let(:depositor)   { FactoryBot.create(:contributor) }
    let(:collection)  { FactoryBot.create(:team, depositor: depositor.ms_id) }

    before do
      subject.instance_variable_set(:@collection, collection)
      subject.get_object_ids
    end

    it 'sets @object_ids' do
      expect(subject.instance_variable_get(:@object_ids)).to eq([])
      expect(subject.instance_variable_get(:@media_count)).to eq(0)
    end
  end

end
