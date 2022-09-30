require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::ProjectsController, type: :controller do

  let(:user)                    { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
  let(:project)                 { Collection.create(title: ['project'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }

  before do
    project.create_collection_groups
  end

  describe "search_builder_class" do
    it{ expect(subject.search_builder_class).to eq(Morphosource::Collections::MediaSearchBuilder) }
  end

  describe ".configure_facets" do
    let(:facet_fields)  { described_class.blacklight_config.facet_fields}
    before do
      allow_any_instance_of(described_class).to receive(:search_builder_class).and_return("search_builder_class")
      described_class.configure_facets
    end
    describe 'publication status' do
      subject { facet_fields['publication_status_ssi']}
      it 'has a publication status facet' do
        expect(subject.label).to eq("Publication Status")
        expect(subject.limit).to eq(10)
      end
    end
    describe 'media type' do
      subject { facet_fields['human_readable_media_type_ssim']}
      it 'has a media type facet' do
        expect(subject.label).to eq("Media Type")
        expect(subject.limit).to eq(10)
      end
    end
    describe 'organization' do
      subject { facet_fields['media_organization_ssim']}
      it 'has an organization facet' do
        expect(subject.label).to eq("Organization")
        expect(subject.limit).to eq(10)
      end
    end
    describe 'project' do
      subject { facet_fields['member_of_project_ids_ssim'] }
      it 'has a project facet' do
        expect(subject.label).to eq("Project")
        expect(subject.limit).to eq(10)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end
    describe 'team' do
      subject { facet_fields['member_of_team_ids_ssim'] }
      it 'has a team facet' do
        expect(subject.label).to eq("Team")
        expect(subject.limit).to eq(10)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end
    describe 'data manager' do
      subject { facet_fields['user_with_ownership_ssi'] }
      it 'has a data manager facet' do
        expect(subject.label).to eq("Data Manager")
        expect(subject.limit).to eq(10)
        expect(subject.helper_method).to eq(:user_name_by_id)
      end
    end
    describe 'depositor' do
      subject { facet_fields['depositor_ssim'] }
      it 'has a depositor facet' do
        expect(subject.label).to eq("Depositor")
        expect(subject.limit).to eq(10)
        expect(subject.helper_method).to eq(:user_name_by_id)
      end
    end
  end

  describe 'tab' do
    it {expect(subject.send(:tab)).to eq(:media) }
  end

  describe 'presenter_class' do
    it {expect(subject.presenter_class).to eq(Morphosource::Collections::ProjectPresenter) }
  end
end
