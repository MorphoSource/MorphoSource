# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Dashboard::LinkedTeamsController, type: :controller do
  let(:org1)                  { Organization.new(id: 'org1', title: ['title'], institution_code: ['ABC'])}
  let(:org2)                  { Organization.create( id: 'org2', title: ['title'], institution_code: ['DEF'], team_id: [team.id])}
  let(:team_collection_type)  { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
  let(:team)                  { Collection.new(id: 'teamid', title: ['Team_A'], collection_type_gid: team_collection_type.gid, depositor: 'abcdef') }
  let(:admin)                 { User.create(id: 'admin', email: 'email@email.com', password: 'password')}
  let(:params)                { { id: team.id, collection: { organization_id: org1.id } } }

  before do
    allow(Organization).to receive(:find).with(org1.id).and_return(org1)
    allow(Organization).to receive(:find).with(org2.id).and_return(org2)
    allow(Collection).to receive(:find).with(team.id).and_return(team)

    sign_in admin
  end


  describe '#link_organization' do
    context 'the current user is not an admin' do
      it 'should not call #clear_organization or #add_organization' do
        expect(subject).to_not receive(:clear_organization)
        expect(subject).to_not receive(:add_organization)
        post :link_organization, params: params
      end
    end
    context 'the current user is an admin' do
      before do
        allow(subject.current_user).to receive(:admin?).and_return(true)
        request.env["HTTP_REFERER"] = "original_page"
        post :link_organization, params: params
      end
      context 'the team already has a linked organization' do
        before do
          allow(Organization).to receive(:where).with(team_id: team.id).and_return([org2])
        end
        it 'clears the old organization' do
          expect(org2.reload.team_id).to eq([])
        end
        it 'adds the new organization' do
          expect(org1.team_id).to eq([team.id])
        end
        it 'redirects back to the collection dashboard page' do
          expect(response).to redirect_to("original_page")
        end
      end
      context 'the team does not already have a linked organization' do
        it 'adds the new organization' do
          expect(org1.team_id).to eq([team.id])
        end
        it 'redirects back to the collection dashboard page' do
          expect(response).to redirect_to("original_page")
        end
      end
    end
  end
end
