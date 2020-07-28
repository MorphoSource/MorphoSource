require 'rails_helper'

RSpec.describe Hyrax::Dashboard::CollectionsController, type: :controller do
  routes { Hyrax::Engine.routes }

  let(:public)      { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

  let(:ability) { double Ability }

  let(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 77) }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: 'Another', machine_id: 99) }
  let(:user) { User.create(display_name: 'John Doe', email: 'johndoe@email.com', password: 'password', ms_id: 'abc123') }

  let(:team) { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id, visibility: public) }

  let(:project) { Collection.create(title: ['Project_B'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id, visibility: public) }

  let(:role) { Role.new(name: 'role') }

  let!(:org1)                  { Organization.create(title: ['old organization'], institution_code: ['DEF'], team_id: [team.id]) }

  let(:specimen)         { BiologicalSpecimen.create(title: ['specimen'], vouchered: [true], depositor: user.ms_id) }
  let(:cho)              { CulturalHeritageObject.create(title: ['cho'], vouchered: [true], depositor: user.ms_id) }
  let(:imagingEvent)     { ImagingEvent.create(title: ['imagingEvent'], depositor: user.ms_id) }
  let(:media)            { Media.create(title: ['new media'], depositor: user.ms_id) }
  let(:team_manager)     { User.create(email: 'manager@test.com', password: 'password') }
  let(:team_depositor)   { User.create(email: 'depositor@test.com', password: 'password') }
  let(:team_viewer)      { User.create(email: 'viewer@test.com', password: 'password') }
  let(:works)             { [org1, specimen, imagingEvent, media] }

  let(:presenter) { described_class.new(SolrDocument.new(team.to_solr), ability, nil) }

  before do
    allow(subject.current_user).to receive(:user?).and_return(true)
    request.env['HTTP_REFERER'] = 'original_page'

    org1.ordered_members << specimen
    specimen.ordered_members << imagingEvent
    imagingEvent.ordered_members << media

    works.each(&:save)
    works.each(&:reload)

    team.create_collection_groups
    sign_in user
  end

  #scenario 'Team Dashboard collections should redirect to edit page' do
  #  get :show, params: { id: team.id }
  #  expect(response).to redirect_to "/dashboard/collections/" + team.id + "/edit"
  #end
#
#  #scenario 'Project Dashboard collections should redirect to edit page' do
#  #  get :show, params: { id: project.id }
#  #  expect(response).to redirect_to "/dashboard/collections/" + project.id + "/edit"
  #end

  describe '#paginated_bso_item_list' do
    before do
      doc = SolrDocument.new(specimen.to_solr)
      docs = [doc]
      controller.instance_variable_set(:@bso_member_docs, docs)
    end
    it 'returns a paginated array' do
      result = controller.send(:paginated_bso_item_list)
      expect(result.count).to eq(1)
    end
  end

  describe '#paginated_cho_item_list' do
    before do
      doc = SolrDocument.new(cho.to_solr)
      docs = [doc]
      controller.instance_variable_set(:@cho_member_docs, docs)
    end
    it 'returns a paginated array' do
      result = controller.send(:paginated_cho_item_list)
      expect(result.count).to eq(1)
    end
  end

  describe '#paginated_media_item_list' do
    before do
      doc = SolrDocument.new(media.to_solr)
      docs = [doc]
      controller.instance_variable_set(:@media_member_docs, docs)
    end
    it 'returns a paginated array' do
      result = controller.send(:paginated_media_item_list)
      expect(result.count).to eq(1)
    end
  end

  describe '#edit' do
    before do
      allow(ability).to receive(:can?).with(:edit, team.id).and_return(true)
      allow(controller).to receive(:authorize!).with(:edit, team).and_return(true)
      allow(controller).to receive(:collection).and_return(team)
      allow(controller).to receive(:presenter).and_return(nil)
      allow(controller).to receive(:query_collection_members).and_return(nil)      
      allow(controller).to receive(:form).and_return(nil)
    end 
    it 'should have TeamPresenter' do
      controller.edit
      expect(controller.presenter_class).to be(Hyrax::TeamPresenter)
    end
  end

end

