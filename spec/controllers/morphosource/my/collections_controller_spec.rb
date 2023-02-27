require 'rails_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::My::CollectionsController, type: :controller do
  let(:user)  { User.create(email: 'user@email.com', password: 'password') }

  describe ".configure_facets" do
    let(:facet_fields)  { described_class.blacklight_config.facet_fields}
    before do
      allow_any_instance_of(described_class).to receive(:search_builder_class).and_return("search_builder_class")
      described_class.configure_facets
    end
    describe 'visibility' do
      subject { facet_fields['visibility_ssi']}
      it 'has a record visibility facet' do
        expect(subject.label).to eq("Visibility")
      end
    end
    describe 'type' do
      subject { facet_fields['human_readable_type_ssim']}
      it 'has a collection type facet' do
        expect(subject.label).to eq("Collection Type")
        expect(subject.limit).to eq(10)
      end
    end
  end

  describe 'search_builder_class' do
    it { expect(controller.search_builder_class).to eq(Morphosource::My::CollectionsSearchBuilder) }
  end

  describe 'search_facet_path' do
    let(:id) { "id" }

    it 'is collections#facet' do
      expect(controller.send(:search_facet_path, {:id => id})).to eq( "/dashboard/my/collections/facet/#{id}?locale=en")
    end
  end

  describe 'search_action_url' do
    it 'is collections#index' do
      expect(controller.send(:search_action_url, [])).to include("/dashboard/my/collections?locale=en")
    end
  end
end
