require 'rails_helper'

RSpec.describe Morphosource::Collections::PermissionsCreateService do
  let(:depositor)       { User.create(email: 'email@email.com', password: 'password') }
  let(:collection)      { Collection.create(id: 'team', title: ['Team'], depositor: depositor.ms_id, collection_type_gid: team_collection_type.gid) }

  before do
    collection.create_collection_groups
  end

  describe 'create_default' do
    before do
      described_class.create_default(collection: collection)
    end

    it "creates a permission template for the collection" do
      expect(Hyrax::PermissionTemplate.find_by_source_id(collection.id)).to be_persisted
    end

    it "creates the default permission template access entries for a team or project collection" do
      expect(Hyrax::PermissionTemplate.find_by_source_id(collection.id).access_grants.count).to eq 6
    end

    describe 'template access grants' do
      let(:access_grants) { collection.permission_template.access_grants }

      describe 'admin group' do
        let(:admin_access_grant) { access_grants.detect{ |grant| grant.agent_id == 'admin'} }

        it 'creates an access grant for the admin group' do
          expect(admin_access_grant.agent_type).to eq('group')
          expect(admin_access_grant.access).to eq(Hyrax::PermissionTemplateAccess::MANAGE)
        end
      end

      describe 'managers group' do
        let(:managers_access_grant) { access_grants.detect{ |grant| grant.agent_id == 'team_managers'} }

        it 'creates an access grant for the admin group' do
          expect(managers_access_grant.agent_type).to eq('group')
          expect(managers_access_grant.access).to eq(Hyrax::PermissionTemplateAccess::MANAGE)
        end
      end

      describe 'editors group' do
        let(:editors_access_grant) { access_grants.detect{ |grant| grant.agent_id == 'team_editors'} }

        it 'creates an access grant for the admin group' do
          expect(editors_access_grant.agent_type).to eq('group')
          expect(editors_access_grant.access).to eq(Hyrax::PermissionTemplateAccess::EDIT_WORKS)
        end
      end

      describe 'depositors group' do
        let(:depositors_access_grant) { access_grants.detect{ |grant| grant.agent_id == 'team_depositors'} }

        it 'creates an access grant for the admin group' do
          expect(depositors_access_grant.agent_type).to eq('group')
          expect(depositors_access_grant.access).to eq(Hyrax::PermissionTemplateAccess::DEPOSIT)
        end
      end

      describe 'downloaders group' do
        let(:downloaders_access_grant) { access_grants.detect{ |grant| grant.agent_id == 'team_downloaders'} }

        it 'creates an access grant for the admin group' do
          expect(downloaders_access_grant.agent_type).to eq('group')
          expect(downloaders_access_grant.access).to eq(Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS)
        end
      end

      describe 'viewers group' do
        let(:viewers_access_grant) { access_grants.detect{ |grant| grant.agent_id == 'team_viewers'} }

        it 'creates an access grant for the admin group' do
          expect(viewers_access_grant.agent_type).to eq('group')
          expect(viewers_access_grant.access).to eq(Hyrax::PermissionTemplateAccess::VIEW)
        end
      end
    end
  end
end
