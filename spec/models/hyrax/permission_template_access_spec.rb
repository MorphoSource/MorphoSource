# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::PermissionTemplateAccess do
  let(:depositor)            { User.create(email: 'depositor@email.com', password: 'password') }
  let(:downloader)           { User.create(email: 'downloader@email.com', password: 'password') }
  let(:collection)           { Collection.create(id: 'team', title: ['Team'], depositor: depositor.ms_id, collection_type_gid: team_collection_type.to_global_id) }

  before do
    collection.create_collection_groups
    Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)

    collection.reset_access_controls!
  end

  describe 'default team/project template grants #label, #admin_group, #destroy' do
    let(:access_grants) { collection.permission_template.access_grants }

    context 'with the admin users group' do
      subject { access_grants.detect{ |grant| grant[:agent_id] == 'admin' } }

      describe '#label' do
        it 'returns the repo admins label' do
          expect(subject.label).to eq 'Repository Administrators'
        end
      end
      describe '#admin_group?' do
        it 'returns true' do
          expect(subject).to be_admin_group
        end
      end
      describe '#destroy' do
        it 'destroys the permission template access record' do
          subject.destroy
          expect(subject).to be_destroyed
        end
      end
    end

    context 'with the managers group' do
      subject { access_grants.detect{ |grant| grant[:access] == "manage" && grant[:agent_id] == 'team_managers' } }

      describe '#label' do
        it 'returns the collection editors label' do
          expect(subject.label).to eq 'team_managers'
        end
      end
      describe '#admin_group?' do
        it 'returns false' do
          expect(subject).not_to be_admin_group
        end
      end
      describe '#destroy' do
        it 'destroys the permission template access record' do
          subject.destroy
          expect(subject).to be_destroyed
        end
      end
    end

    context 'with the editors group' do
      subject { access_grants.detect{ |grant| grant[:access] == "edit_works" } }

      describe '#label' do
        it 'returns the collection editors label' do
          expect(subject.label).to eq 'team_editors'
        end
      end
      describe '#admin_group?' do
        it 'returns false' do
          expect(subject).not_to be_admin_group
        end
      end
      describe '#destroy' do
        it 'destroys the permission template access record' do
          subject.destroy
          expect(subject).to be_destroyed
        end
      end
    end

    context 'with the depositors group' do
      subject { access_grants.detect{ |grant| grant[:access] == "deposit" } }

      describe '#label' do
        it 'returns the collection editors label' do
          expect(subject.label).to eq 'team_depositors'
        end
      end
      describe '#admin_group?' do
        it 'returns false' do
          expect(subject).not_to be_admin_group
        end
      end
      describe '#destroy' do
        it 'destroys the permission template access record' do
          subject.destroy
          expect(subject).to be_destroyed
        end
      end
    end

    context 'with the downloaders group' do
      subject { access_grants.detect{ |grant| grant[:access] == "download" } }

      describe '#label' do
        it 'returns the collection downloaders label' do
          expect(subject.label).to eq 'team_downloaders'
        end
      end
      describe '#admin_group?' do
        it 'returns false' do
          expect(subject).not_to be_admin_group
        end
      end
      describe '#destroy' do
        it 'destroys the permission template access record' do
          subject.destroy
          expect(subject).to be_destroyed
        end
      end
    end

    context 'with the viewers group' do
      subject { access_grants.detect{ |grant| grant[:access] == "view" } }

      describe '#label' do
        it 'returns the collection viewers label' do
          expect(subject.label).to eq 'team_viewers'
        end
      end
      describe '#admin_group?' do
        it 'returns false' do
          expect(subject).not_to be_admin_group
        end
      end
      describe '#destroy' do
        it 'destroys the permission template access record' do
          subject.destroy
          expect(subject).to be_destroyed
        end
      end
    end

    context 'with a user that is a collection viewer' do
      let(:permission_template_access) { Hyrax::PermissionTemplateAccess.create!(permission_template: collection.permission_template, agent_type: 'user', agent_id: 'agent_id', access: Hyrax::PermissionTemplateAccess::VIEW) }

      subject { permission_template_access }

      describe '#label' do
        it 'returns the user label' do
          expect(subject.label).to eq 'agent_id'
        end
      end
      describe '#admin_group?' do
        it 'returns false' do
          expect(subject).not_to be_admin_group
        end
      end
      describe '#destroy' do
        it 'carries out the destroy operation' do
          subject.destroy
          expect(subject).to be_destroyed
          expect(subject.errors).to be_empty
        end
      end
    end

    context 'with a user that is a collection downloader' do
      let(:permission_template_access) { Hyrax::PermissionTemplateAccess.create!(permission_template: collection.permission_template, agent_type: 'user', agent_id: 'agent_id', access: Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS) }

      subject { permission_template_access }

      describe '#label' do
        it 'returns the user label' do
          expect(subject.label).to eq 'agent_id'
        end
      end
      describe '#admin_group?' do
        it 'returns false' do
          expect(subject).not_to be_admin_group
        end
      end
      describe '#destroy' do
        it 'carries out the destroy operation' do
          subject.destroy
          expect(subject).to be_destroyed
          expect(subject.errors).to be_empty
        end
      end
    end

    context 'with a user that is a collection depositor' do
      let(:permission_template_access) { Hyrax::PermissionTemplateAccess.create!(permission_template: collection.permission_template, agent_type: 'user', agent_id: 'agent_id', access: Hyrax::PermissionTemplateAccess::DEPOSIT) }

      subject { permission_template_access }

      describe '#label' do
        it 'returns the user label' do
          expect(subject.label).to eq 'agent_id'
        end
      end
      describe '#admin_group?' do
        it 'returns false' do
          expect(subject).not_to be_admin_group
        end
      end
      describe '#destroy' do
        it 'carries out the destroy operation' do
          subject.destroy
          expect(subject).to be_destroyed
          expect(subject.errors).to be_empty
        end
      end
    end

    context 'with a user that is a collection editor' do
      let(:permission_template_access) { Hyrax::PermissionTemplateAccess.create!(permission_template: collection.permission_template, agent_type: 'user', agent_id: 'agent_id', access: Hyrax::PermissionTemplateAccess::EDIT_WORKS) }

      subject { permission_template_access }

      describe '#label' do
        it 'returns the user label' do
          expect(subject.label).to eq 'agent_id'
        end
      end
      describe '#admin_group?' do
        it 'returns false' do
          expect(subject).not_to be_admin_group
        end
      end
      describe '#destroy' do
        it 'carries out the destroy operation' do
          subject.destroy
          expect(subject).to be_destroyed
          expect(subject.errors).to be_empty
        end
      end
    end

    context 'with a user that is a collection manager' do
      let(:permission_template_access) { Hyrax::PermissionTemplateAccess.create!(permission_template: collection.permission_template, agent_type: 'user', agent_id: 'agent_id', access: Hyrax::PermissionTemplateAccess::MANAGE) }

      subject { permission_template_access }

      describe '#label' do
        it 'returns the user label' do
          expect(subject.label).to eq 'agent_id'
        end
      end
      describe '#admin_group?' do
        it 'returns false' do
          expect(subject).not_to be_admin_group
        end
      end
      describe '#destroy' do
        it 'carries out the destroy operation' do
          subject.destroy
          expect(subject).to be_destroyed
          expect(subject.errors).to be_empty
        end
      end
    end
  end
end
