require 'rails_helper'

RSpec.describe Morphosource::My::Collections::OrganizationCollectionsController, type: :controller do

  describe 'configure_facets' do
    let(:facet_fields)  { described_class.blacklight_config.facet_fields }

    before do
      described_class.configure_facets
    end

    describe 'institution' do
      subject { facet_fields["institution"]}
      it 'has a media type facet' do
        expect(subject.field).to eq("institution_name_ssim")
        expect(subject.label).to eq("Institution")
        expect(subject.limit).to eq(10)
      end
    end

    describe 'organization' do
      subject { facet_fields["organization"]}
      it 'has an organization facet' do
        expect(subject.field).to eq("title_ssi")
        expect(subject.label).to eq("Organization")
        expect(subject.limit).to eq(10)
      end
    end

    describe 'organization_type' do
      subject { facet_fields["organization_type"]}
      it 'has an organization_type facet' do
        expect(subject.field).to eq("organization_type_ssim")
        expect(subject.label).to eq("Organization Type")
        expect(subject.limit).to eq(10)
      end
    end

    describe 'country' do
      subject { facet_fields["country"]}
      it 'has a country facet' do
        expect(subject.field).to eq("country_ssim")
        expect(subject.label).to eq("Country")
        expect(subject.limit).to eq(10)
      end
    end

    describe 'state' do
      subject { facet_fields["state"]}
      it 'has a state facet' do
        expect(subject.field).to eq("state_province_ssim")
        expect(subject.label).to eq("State or Province")
        expect(subject.limit).to eq(10)
      end
    end

    describe 'city' do
      subject { facet_fields["city"]}
      it 'has a city facet' do
        expect(subject.field).to eq("city_ssim")
        expect(subject.label).to eq("City")
        expect(subject.limit).to eq(10)
      end
    end
  end


  describe 'temporary admin-only restriction' do
    before do
      sign_in user
    end

    context 'user is an admin' do
      let(:user)  { FactoryBot.create(:admin) }

      it 'responds with a 200' do
        get :index
        expect(response.status).to eq(200)
      end
    end

    context 'user is not an admin' do
      let(:user)  { FactoryBot.create(:contributor) }

      it 'responds with a 200' do
        get :index
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'collections_type' do
    it { expect(subject.collections_type).to eq('organizations') }
  end

  describe 'search_builder_class' do
    it { expect(subject.search_builder_class).to be(Morphosource::My::Collections::OrganizationsSearchBuilder) }
  end

  describe 'search_action_url' do
    it 'is media_list_path' do
      expect(subject.search_action_url).to include("/dashboard/my/organizations?locale=en")
    end
  end

  describe 'search_action_for_dashboard' do
    it { expect(subject.search_action_for_dashboard).to eq("/dashboard/my/organizations?locale=en") }
  end
end
