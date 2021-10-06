require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::TeamsController, type: :controller do

  let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
  let(:team)                    { Collection.create(title: ['team'], collection_type_gid: team_collection_type.gid) }

  describe "search_builder_class" do
    it { expect(subject.search_builder_class).to eq(Morphosource::Collections::MediaSearchBuilder) }
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
        expect(subject.limit).to eq(nil)
      end
    end
    describe 'media type' do
      subject { facet_fields['human_readable_media_type_ssim']}
      it 'has a media type facet' do
        expect(subject.label).to eq("Media Type")
        expect(subject.limit).to eq(nil)
      end
    end
    describe 'organization' do
      subject { facet_fields['media_organization_ssim']}
      it 'has an organization facet' do
        expect(subject.label).to eq("Organization")
        expect(subject.limit).to eq(nil)
      end
    end
    describe 'project' do
      subject { facet_fields['member_of_project_ids_ssim'] }
      it 'has a project facet' do
        expect(subject.label).to eq("Project")
        expect(subject.limit).to eq(nil)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end
    describe 'team' do
      subject { facet_fields['member_of_team_ids_ssim'] }
      it 'has a team facet' do
        expect(subject.label).to eq("Team")
        expect(subject.limit).to eq(nil)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end
  end

  describe 'tab' do
    it {expect(subject.send(:tab)).to eq(:media) }
  end

  describe 'filtered_facets' do
    it 'lists facets to be filtered by access' do
      expect(subject.send(:filtered_facets)).to match_array(["member_of_project_ids_ssim", "member_of_team_ids_ssim"])
    end
  end

  describe 'removed_facets' do
    before { subject.instance_variable_set(:@collection, team) }
    it { expect(subject.send(:removed_facets)).to match_array([]) }
  end

  describe 'presenter_class' do
    it {expect(subject.presenter_class).to eq(Morphosource::Collections::TeamPresenter) }
  end

  describe 'create_intersections_facet' do
    let(:facet_fields)        { subject.blacklight_config.facet_fields}
    let(:intersections_facet) { facet_fields["intersections"] }

    context 'team is linked to an organization' do
      let!(:organization)  { Organization.create(title: ['Linked Organization'], team_id: [team.id]) }
      before do
        subject.instance_variable_set(:@collection, team)
        allow(subject).to receive(:load_collection).and_return(true)
        get :show, params: { id: team.id }
      end
      it 'has an intersections facet' do
        expect(intersections_facet.label).to eq("Intersections")
        expect(intersections_facet.limit).to eq(nil)
        # organization
        expect(intersections_facet.query["organization"][:label]).to eq("All media of organization physical objects")
        expect(intersections_facet.query["organization"][:fq]).to eq("media_organization_id_ssim:#{organization.id}")
        # team
        expect(intersections_facet.query["team"][:label]).to eq('All media owned by team')
        expect(intersections_facet.query["team"][:fq]).to eq("member_of_team_ids_ssim:#{team.id}")
        # team and organization
        expect(intersections_facet.query["team_and_organization"][:label]).to eq('Media owned by team AND of organization physical objects')
        expect(intersections_facet.query["team_and_organization"][:fq]).to eq("media_organization_id_ssim:#{organization.id} AND member_of_team_ids_ssim:#{team.id}")
        # organization not team
        expect(intersections_facet.query["organization_not_team"][:label]).to eq('Media of organization physical objects NOT owned by team')
        expect(intersections_facet.query["organization_not_team"][:fq]).to eq("media_organization_id_ssim:#{organization.id} NOT member_of_team_ids_ssim:#{team.id}")
        # team not organization
        expect(intersections_facet.query["team_not_organization"][:label]).to eq('Media owned by team NOT of organization physical objects')
        expect(intersections_facet.query["team_not_organization"][:fq]).to eq("member_of_team_ids_ssim:#{team.id} NOT media_organization_id_ssim:#{organization.id}")

      end
    end
    context 'team is not linked to an organization' do
      it 'does not have an intersections facet' do
        expect(intersections_facet).to be(nil)
      end
    end
  end
end
