# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Collections::PermissionsCreateService do
  let(:another_collection_type) { Hyrax::CollectionType.create(title: 'Another', machine_id: 99) }

  let(:depositor) { FactoryBot.create(:contributor) }
  let(:team_a)    { Collection.create(title: ['Team A'], collection_type_gid: team_collection_type.to_global_id, depositor: depositor.ms_id) }
  let(:project_a) { Collection.create(title: ['Project A'], collection_type_gid: project_collection_type.to_global_id, depositor: depositor.ms_id) }
  let(:another)   { Collection.create(title: ['Another'], collection_type_gid: another_collection_type.to_global_id, depositor: depositor.ms_id) }

  let(:user) { User.create(email: 'email@email.com', password: 'password', ms_id: 'abc123') }

  let(:collections)       { [team_a, project_a, another] }
  let(:collection_types)  { [team_collection_type, project_collection_type, another_collection_type] }

  before do
    # Hyrax::PermissionTemplate.destroy_all
    collections.each do |collection|
      collection.create_collection_groups
      # Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)
    end
  end

  describe '#create_default' do
    let(:access_grants)   { collection.permission_template.access_grants }
    let(:admin)           { access_grants.find_by(agent_id: 'admin') }

    Collection::DEFAULT_GROUP_ROLES.each do |role|
      let(role.to_sym) { access_grants.find_by(agent_id: "#{collection.id}_#{role}") }
    end

    before do
      collection_types.each do |type|
        allow(Hyrax::CollectionType).to receive(:find_by_gid!).with(type.to_global_id).and_return(type)
      end
      collections.each do |collection|
        Collection::DEFAULT_GROUP_ROLES.each do |role|
          allow(collection).to receive_message_chain("#{role}_group.name").and_return("#{collection.id}_#{role}")
        end
      end
      allow_any_instance_of(Collection).to receive(:add_depositor_to_managers).and_return(true)

      described_class.create_default(collection: collection)
    end

    context 'user creates a new team' do
      let(:collection) { team_a }

      it 'assigns admins and collection groups to appropriate access levels' do
        expect(access_grants.count).to be(6)
        expect(admin[:access]).to eq(Hyrax::PermissionTemplateAccess::MANAGE)
        expect(managers[:access]).to eq(Hyrax::PermissionTemplateAccess::MANAGE)
        expect(editors[:access]).to eq(Hyrax::PermissionTemplateAccess::EDIT_WORKS)
        expect(depositors[:access]).to eq(Hyrax::PermissionTemplateAccess::DEPOSIT)
        expect(downloaders[:access]).to eq(Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS)
        expect(viewers[:access]).to eq(Hyrax::PermissionTemplateAccess::VIEW)
      end
    end
    context 'user creates a new project' do
      let(:collection) { project_a }

      it 'assigns admins and collection groups to appropriate access levels' do
        expect(access_grants.count).to be(6)
        expect(admin[:access]).to eq(Hyrax::PermissionTemplateAccess::MANAGE)
        expect(managers[:access]).to eq(Hyrax::PermissionTemplateAccess::MANAGE)
        expect(editors[:access]).to eq(Hyrax::PermissionTemplateAccess::EDIT_WORKS)
        expect(depositors[:access]).to eq(Hyrax::PermissionTemplateAccess::DEPOSIT)
        expect(downloaders[:access]).to eq(Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS)
        expect(viewers[:access]).to eq(Hyrax::PermissionTemplateAccess::VIEW)
      end
    end
  end
end
