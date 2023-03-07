require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::TeamsController, type: :controller do

  let(:user)                    { User.create(email: 'user@email.com', password: 'password')}
  let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
  let(:team)                    { Collection.create(title: ['team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }

  describe "search_builder_class" do
    it { expect(subject.search_builder_class).to eq(Morphosource::Collections::MediaSearchBuilder) }
  end

  describe 'tab' do
    it {expect(subject.send(:tab)).to eq(:media) }
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
        team.create_collection_groups
        Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
        subject.instance_variable_set(:@collection, team)
        allow(subject).to receive(:load_collection).and_return(true)
        allow(subject).to receive(:authorize_collection).and_return(true)
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

  # helpers/morphosource/my/works_helper
  describe '#search_action_for_dashboard' do
    let(:main_app)    { Rails.application.routes.url_helpers }
    let(:params)      { { controller: controller.controller_path } }
    let(:collection)  { double('collection', id: 'abc')}
    subject           { controller.view_context }

    before do
      allow(subject).to receive(:params).and_return(params)
      subject.instance_variable_set(:@collection, collection)
    end

    it { expect(subject.search_action_for_dashboard).to eq(main_app.team_media_path(id: collection.id, locale: 'en')) }
  end
end
