# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Admin::DataCurationController, type: :controller do

  let(:admin)                   { User.create(email: 'admin@email.com', password: 'password') }
  let(:admin_role)              { Role.create(name: 'admin') }
  let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
  let(:team)                    { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, depositor: admin.ms_id) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
  let!(:project)                { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.gid, depositor: admin.ms_id) }
  let!(:organization)           { Organization.create(title: ['Organization'], team_id: [team.id])}

  before do
    admin_role.users << admin
    admin_role.save
  end

  describe 'apply_permission_template' do
    let(:params) { { team_id: team.id, project_id: project.id, email: admin.email, update_publication_status: 'all' } }

    context 'admin is not logged in' do
      it 'does not call apply_permission_template' do
        expect(subject).not_to receive(:apply_permission_template)
        post :apply_permission_template, params: params
      end
    end

    context 'admin is logged in' do
      before do
        sign_in admin
      end

      it 'calls apply_permission_template' do
        expect(subject).to receive(:apply_permission_template)
        post :apply_permission_template, params: params
      end

      it 'calls the organization normalization service' do
        expect(Morphosource::DataCuration::OrganizationNormalizationService).to receive(:call).with(params)
        post :apply_permission_template, params: params
      end

      it 'redirects to the team' do
        post :apply_permission_template, params: params
        expect(response).to redirect_to(team_media_path(team))
      end
    end
  end
end
