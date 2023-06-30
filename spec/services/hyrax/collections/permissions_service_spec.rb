# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Collections::PermissionsService do
  let(:user)                 { User.create(email: 'user@example.com', password: 'password') }

  context 'collection specific methods' do
    let(:collection)           { Collection.create(id: 'team', title: ['Team'], depositor: user.ms_id, collection_type_gid: team_collection_type.gid) }
    let(:admin_set) { AdminSet.create(id: 'adminset_1') }
    let(:col_permission_template) { collection.permission_template }
    let(:as_permission_template) { Hyrax::PermissionTemplate.create(source_id: admin_set.id) }

    before do
      collection.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)

      collection.reset_access_controls!

      allow(Hyrax::PermissionTemplate).to receive(:find_by!).with(source_id: collection.id).and_return(col_permission_template)
    end

    context 'when manage user' do
      let(:manage_user) { User.create(email: 'manage@email.com', password: 'password') }
      let(:ability)     { Ability.new(manage_user) }

      before do
        Hyrax::PermissionTemplateAccess.create(permission_template: collection.permission_template, agent_type: 'user', agent_id: manage_user.ms_id, access: Hyrax::PermissionTemplateAccess::MANAGE)
      end

      subject { described_class }

      it '.can_deposit_in_collection? returns true' do
        expect(subject.can_deposit_in_collection?(collection_id: collection.id, ability: ability)).to be true
      end
      it '.can_view_admin_show_for_collection? returns true' do
        expect(subject.can_view_admin_show_for_collection?(collection_id: collection.id, ability: ability)).to be true
      end
    end

    context 'when edit user' do
      let(:ability)   { Ability.new(edit_user) }
      let(:edit_user) { User.create(email: 'edit@email.com', password: 'password') }

      before do
        Hyrax::PermissionTemplateAccess.create(permission_template: collection.permission_template, agent_type: 'user', agent_id: edit_user.ms_id, access: Hyrax::PermissionTemplateAccess::EDIT_WORKS)
      end

      subject { described_class }

      it '.can_deposit_in_collection? returns true' do
        expect(subject.can_deposit_in_collection?(collection_id: collection.id, ability: ability)).to be true
      end
      it '.can_view_admin_show_for_collection? returns true' do
        expect(subject.can_view_admin_show_for_collection?(collection_id: collection.id, ability: ability)).to be true
      end
    end

    context 'when deposit user' do
      let(:ability)      { Ability.new(deposit_user) }
      let(:deposit_user) { User.create(email: 'deposit@email.com', password: 'password') }

      before do
        Hyrax::PermissionTemplateAccess.create(permission_template: collection.permission_template, agent_type: 'user', agent_id: deposit_user.ms_id, access: Hyrax::PermissionTemplateAccess::DEPOSIT)
      end

      subject { described_class }

      it '.can_deposit_in_collection? returns true' do
        expect(subject.can_deposit_in_collection?(collection_id: collection.id, ability: ability)).to be true
      end
      it '.can_view_admin_show_for_collection? returns true' do
        expect(subject.can_view_admin_show_for_collection?(collection_id: collection.id, ability: ability)).to be true
      end
    end

    context 'when download user' do
      let(:ability)       { Ability.new(download_user) }
      let(:download_user) { User.create(email: 'download@email.com', password: 'password') }

      before do
        Hyrax::PermissionTemplateAccess.create(permission_template: collection.permission_template, agent_type: 'user', agent_id: download_user.ms_id, access: Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS)
      end

      subject { described_class }

      it '.can_deposit_in_collection? returns false' do
        expect(subject.can_deposit_in_collection?(collection_id: collection.id, ability: ability)).to be false
      end
      it '.can_view_admin_show_for_collection? returns true' do
        expect(subject.can_view_admin_show_for_collection?(collection_id: collection.id, ability: ability)).to be true
      end
    end

    context 'when view user' do
      let(:ability)   { Ability.new(view_user) }
      let(:view_user) { User.create(email: 'view@email.com', password: 'password') }

      before do
        Hyrax::PermissionTemplateAccess.create!(permission_template: collection.permission_template, agent_type: 'user', agent_id: view_user.ms_id, access: Hyrax::PermissionTemplateAccess::VIEW)
      end

      subject { described_class }

      it '.can_deposit_in_collection? returns false' do
        expect(subject.can_deposit_in_collection?(collection_id: collection.id, ability: ability)).to be false
      end
      it '.can_view_admin_show_for_collection? returns true' do
        expect(subject.can_view_admin_show_for_collection?(collection_id: collection.id, ability: ability)).to be true
      end
    end

    context 'when public group deposit user' do
      let(:deposit_user)  { User.create(email: 'deposit@email.com', password: 'password') }
      let(:ability)       { Ability.new(deposit_user) }

      context 'thru membership in public group' do
        before do
          allow(ability).to receive(:user_groups).and_return(['public'])
          Hyrax::PermissionTemplateAccess.create(permission_template: collection.permission_template, agent_type: 'group', agent_id: 'public', access: Hyrax::PermissionTemplateAccess::DEPOSIT)
        end

        subject { described_class }

        it '.can_deposit_in_collection? returns true' do
          expect(subject.can_deposit_in_collection?(collection_id: collection.id, ability: ability)).to be true
        end
        it '.can_view_admin_show_for_collection? returns false' do
          expect(subject.can_view_admin_show_for_collection?(collection_id: collection.id, ability: ability)).to be false
        end
      end

      context 'thru membership in registered group' do
        before do
          allow(ability).to receive(:user_groups).and_return(['registered'])
          Hyrax::PermissionTemplateAccess.create(permission_template: collection.permission_template, agent_type: 'group', agent_id: 'registered', access: Hyrax::PermissionTemplateAccess::DEPOSIT)
        end

        subject { described_class }

        it '.can_deposit_in_collection? returns true' do
          expect(subject.can_deposit_in_collection?(collection_id: collection.id, ability: ability)).to be true
        end
        it '.can_view_admin_show_for_collection? returns false' do
          expect(subject.can_view_admin_show_for_collection?(collection_id: collection.id, ability: ability)).to be false
        end
      end
    end

    context 'when public group download user' do
      let(:download_user)   { User.create(email: 'deposit@email.com', password: 'password') }
      let(:ability)         { Ability.new(download_user) }

      context 'thru membership in public group' do
        before do
          allow(ability).to receive(:user_groups).and_return(['public'])
          Hyrax::PermissionTemplateAccess.create(permission_template: collection.permission_template, agent_type: 'group', agent_id: 'public', access: Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS)
        end

        subject { described_class }

        it '.can_deposit_in_collection? returns false' do
          expect(subject.can_deposit_in_collection?(collection_id: collection.id, ability: ability)).to be false
        end
        it '.can_view_admin_show_for_collection? returns false' do
          expect(subject.can_view_admin_show_for_collection?(collection_id: collection.id, ability: ability)).to be false
        end
      end

      context 'thru membership in registered group' do
        before do
          allow(ability).to receive(:user_groups).and_return(['registered'])
          Hyrax::PermissionTemplateAccess.create(permission_template: collection.permission_template, agent_type: 'group', agent_id: 'registered', access: Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS)
        end

        subject { described_class }

        it '.can_deposit_in_collection? returns false' do
          expect(subject.can_deposit_in_collection?(collection_id: collection.id, ability: ability)).to be false
        end
        it '.can_view_admin_show_for_collection? returns false' do
          expect(subject.can_view_admin_show_for_collection?(collection_id: collection.id, ability: ability)).to be false
        end
      end
    end

    context 'when public group view user' do
      let(:view_user) { User.create(email: 'view@email.com', password: 'password') }
      let(:ability)   { Ability.new(view_user) }

      context 'thru membership in public group' do
        before do
          allow(ability).to receive(:user_groups).and_return(['public'])
          Hyrax::PermissionTemplateAccess.create(permission_template: collection.permission_template, agent_type: 'group', agent_id: 'public', access: Hyrax::PermissionTemplateAccess::VIEW)
        end

        subject { described_class }

        it '.can_deposit_in_collection? returns false' do
          expect(subject.can_deposit_in_collection?(collection_id: collection.id, ability: ability)).to be false
        end
        it '.can_view_admin_show_for_collection? returns false' do
          expect(subject.can_view_admin_show_for_collection?(collection_id: collection.id, ability: ability)).to be false
        end
      end

      context 'thru membership in registered group' do
        before do
          allow(ability).to receive(:user_groups).and_return(['registered'])
          Hyrax::PermissionTemplateAccess.create(permission_template: collection.permission_template, agent_type: 'group', agent_id: 'registered', access: Hyrax::PermissionTemplateAccess::VIEW)
        end

        subject { described_class }

        it '.can_deposit_in_collection? returns false' do
          expect(subject.can_deposit_in_collection?(collection_id: collection.id, ability: ability)).to be false
        end
        it '.can_view_admin_show_for_collection? returns false' do
          expect(subject.can_view_admin_show_for_collection?(collection_id: collection.id, ability: ability)).to be false
        end
      end
    end

    context 'when user without access' do
      let(:no_access_user) { User.create(email: 'noaccess@email.com', password: 'password') }
      let(:ability)   { Ability.new(no_access_user) }

      before do
        allow(ability).to receive(:user_groups).and_return([])
      end

      subject { described_class }

      it '.can_deposit_in_collection? returns false' do
        expect(subject.can_deposit_in_collection?(collection_id: collection.id, ability: ability)).to be false
      end
      it '.can_view_admin_show_for_collection? returns false' do
        expect(subject.can_view_admin_show_for_collection?(collection_id: collection.id, ability: ability)).to be false
      end
    end
  end

  context 'methods returning ids' do
    let(:ability)     { Ability.new(user) }
    let(:user2)       { User.create(email: 'user2@email.com', password: 'password') }

    let(:collection)  { Collection.create(id: 'col1', title: ['collection 1'], depositor: user2.ms_id, collection_type_gid: team_collection_type.gid) }

    let(:collection2) { Collection.create(id: 'col2', title: ['collection 2'], depositor: user2.ms_id, collection_type_gid: team_collection_type.gid) }
    let(:collection3) { Collection.create(id: 'col3', title: ['collection 3'], depositor: user2.ms_id, collection_type_gid: team_collection_type.gid) }
    let(:collections) { [collection, collection2, collection3] }

    before do
      collections.each do |collection|
        collection.create_collection_groups
        Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)
        collection.reset_access_controls!
      end
    end

    describe '.collection_ids_for_user' do
      describe 'manage access' do
        before do
          collection.managers << user
          collection.managers_group.save
          collection.managers_group.reload

          Hyrax::PermissionTemplateAccess.create(permission_template: collection2.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::MANAGE)
        end
        it 'returns collection ids where user has manage access' do
          expect(described_class.collection_ids_for_user(access: 'manage', ability: ability)).to match_array [collection.id, collection2.id]
        end
      end

      describe 'edit works access' do
        before do
          collection.editors << user
          collection.editors_group.save
          collection.editors_group.reload

          Hyrax::PermissionTemplateAccess.create(permission_template: collection3.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::EDIT_WORKS)
        end
        it 'returns collection ids where user has deposit access' do
          expect(described_class.collection_ids_for_user(access: 'edit_works', ability: ability)).to match_array [collection.id, collection3.id]
        end
      end

      describe 'deposit access' do
        before do
          collection.depositors << user
          collection.depositors_group.save
          collection.depositors_group.reload

          Hyrax::PermissionTemplateAccess.create(permission_template: collection2.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::DEPOSIT)
        end
        it 'returns collection ids where user has deposit access' do
          expect(described_class.collection_ids_for_user(access: 'deposit', ability: ability)).to match_array [collection.id, collection2.id]
        end
      end

      describe 'download access' do
        before do
          collection.downloaders << user
          collection.downloaders_group.save
          collection.downloaders_group.reload

          Hyrax::PermissionTemplateAccess.create(permission_template: collection2.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS)
        end
        it 'returns collection ids where user has download access' do
          expect(described_class.collection_ids_for_user(access: 'download', ability: ability)).to match_array [collection.id, collection2.id]
        end
      end

      describe 'view access' do
        before do
          collection.viewers << user
          collection.viewers_group.save
          collection.viewers_group.reload

          Hyrax::PermissionTemplateAccess.create(permission_template: collection2.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::VIEW)
        end
        it 'returns collection ids where user has view access' do
          expect(described_class.collection_ids_for_user(access: 'view', ability: ability)).to match_array [collection.id, collection2.id]
        end
      end

      describe 'all access levels' do
        let(:collection4) { Collection.create(id: 'col4', title: ['collection 4'], depositor: user2.ms_id, collection_type_gid: team_collection_type.gid) }
        let(:collection5) { Collection.create(id: 'col5', title: ['collection 5'], depositor: user2.ms_id, collection_type_gid: team_collection_type.gid) }

        before do
          [collection4, collection5].each do |c|
            c.create_collection_groups
            Morphosource::Collections::PermissionsCreateService.create_default(collection: c)
            c.reset_access_controls!
          end

          collection.managers << user
          collection.managers_group.save
          collection.managers_group.reload

          collection2.editors << user
          collection2.editors_group.save
          collection2.editors_group.reload

          Hyrax::PermissionTemplateAccess.create(permission_template: collection3.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::DEPOSIT)

          Hyrax::PermissionTemplateAccess.create(permission_template: collection4.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::VIEW)

          collection5.downloaders << user
          collection5.downloaders_group.save
          collection5.downloaders_group.reload
        end

        it 'returns collection ids where user has manage, deposit, edit, download, or view access' do
          all = [collection.id, collection2.id, collection3.id, collection4.id, collection5.id]
          expect(described_class.collection_ids_for_user(access: ['manage', 'edit_works', 'deposit', 'download', 'view'], ability: ability)).to match_array all
        end
      end

      context 'when user has no access' do
        let(:ability) { Ability.new(user) }

        it 'returns empty array' do
          expect(described_class.collection_ids_for_user(access: ['manage', 'deposit', 'view'], ability: ability)).to match_array []
        end
      end

      describe 'lists' do
        let(:media_list)                              { MediaList.create(title: ['media_list'], depositor: user2.ms_id, collection_type_gid: media_list_collection_type.gid) }
        let(:sequential_section_list)                 { SequentialSectionList.create(title: ['sequential_section_list'], depositor: user2.ms_id, collection_type_gid: sequential_section_list_collection_type.gid) }

        let(:collections) { [collection, media_list, sequential_section_list] }

        it 'returns collection ids where user has view access' do
          collections.each do |collection|
            collection.viewers << user
            collection.viewers_group.save
            collection.viewers_group.reload
          end
          expect(described_class.collection_ids_for_user(access: 'view', ability: ability)).to match_array(collections.map(&:id))
        end
        it 'returns collection ids where user has manage access' do
          collections.each do |collection|
            collection.managers << user
            collection.managers_group.save
            collection.managers_group.reload
          end
          expect(described_class.collection_ids_for_user(access: ['manage'], ability: ability)).to match_array(collections.map(&:id))
        end
      end
    end

    describe '.source_ids_for_manage' do
      let(:admin_set)  { AdminSet.create(title: ['admin set 1']) }

      before do
        Hyrax::PermissionTemplate.create(source_id: admin_set.id)
      end

      context 'user manages collection and admin set' do
        before do
          collection.managers << user
          collection.managers_group.save
          collection.managers_group.reload

          Hyrax::PermissionTemplateAccess.create(permission_template: admin_set.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::MANAGE)
        end

        it 'returns collection and admin set ids where user has manage access' do
          expect(described_class.source_ids_for_manage(ability: ability)).to match_array [collection.id, admin_set.id]
        end
        it 'returns collection ids where user has manage access' do
          expect(described_class.source_ids_for_manage(ability: ability, source_type: 'collection')).to match_array [collection.id]
        end
        it 'returns admin set ids where user has manage access' do
          expect(described_class.source_ids_for_manage(ability: ability, source_type: 'admin_set')).to match_array [admin_set.id]
        end
      end

      context 'when user has no access' do
        let(:ability) { Ability.new(user) }

        it 'returns empty array' do
          expect(described_class.source_ids_for_manage(ability: ability)).to match_array []
        end
      end
    end

    describe '.source_ids_for_deposit' do
      let(:admin_set)  { AdminSet.create(title: ['admin set 1']) }
      let(:admin_set2) { AdminSet.create(title: ['admin set 2']) }

      before do
        Hyrax::PermissionTemplate.create(source_id: admin_set.id)
        Hyrax::PermissionTemplate.create(source_id: admin_set2.id)
      end

      context 'user can deposit to collection and admin set' do
        before do
          collection.depositors << user
          collection.depositors_group.save
          collection.depositors_group.reload

          Hyrax::PermissionTemplateAccess.create(permission_template: admin_set.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::DEPOSIT)

          Hyrax::PermissionTemplateAccess.create(permission_template: admin_set2.permission_template, agent_type: 'group', agent_id: 'deposit_group', access: Hyrax::PermissionTemplateAccess::DEPOSIT)

          allow(ability).to receive(:user_groups).and_return(ability.user_groups << 'deposit_group')
        end

        it 'returns collection and admin set ids where user has deposit access' do
          expect(described_class.source_ids_for_deposit(ability: ability)).to match_array [collection.id, admin_set.id, admin_set2.id]
        end
        it 'returns collection ids where user has deposit access' do
          expect(described_class.source_ids_for_deposit(ability: ability, source_type: 'collection')).to match_array [collection.id]
        end
        it 'returns admin set ids where user has deposit access' do
          expect(described_class.source_ids_for_deposit(ability: ability, source_type: 'admin_set')).to match_array [admin_set.id, admin_set2.id]
        end
        it 'returns admin set ids where user has deposit access except excluded groups' do
          expect(described_class.source_ids_for_deposit(ability: ability, source_type: 'admin_set', exclude_groups: ['deposit_group']))
            .to match_array [admin_set.id]
        end
      end

      context 'when user has no access' do
        let(:ability) { Ability.new(user) }

        it 'returns empty array' do
          expect(described_class.source_ids_for_deposit(ability: ability)).to match_array []
        end
      end
    end

    describe '.collection_ids_for_edit_works' do
      let(:collection4) { Collection.create(id: 'col4', title: ['collection 4'], depositor: user2.ms_id, collection_type_gid: team_collection_type.gid) }

      context 'user has edit works access through group and individual access' do
        before do
          collection4.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: collection4)
          collection4.reset_access_controls!

          collection.editors << user
          collection.editors_group.save
          collection.editors_group.reload

          collection2.managers << user
          collection2.managers_group.save
          collection2.managers_group.reload

          Hyrax::PermissionTemplateAccess.create(permission_template: collection3.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::MANAGE)

          Hyrax::PermissionTemplateAccess.create(permission_template: collection4.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::EDIT_WORKS)
        end

        it 'returns collection ids where user has edit works access' do
          expect(described_class.collection_ids_for_edit_works(ability: ability)).to match_array [collection.id, collection2.id, collection3.id, collection4.id]
        end
      end

      context 'when user has no access' do
        let(:ability) { Ability.new(user) }

        it 'returns empty array' do
          expect(described_class.collection_ids_for_edit_works(ability: ability)).to match_array []
        end
      end
    end

    describe '.collection_ids_for_deposit' do
      context 'user has deposit access through group and individual access' do
        before do
          collection.depositors << user
          collection.depositors_group.save
          collection.depositors_group.reload

          Hyrax::PermissionTemplateAccess.create(permission_template: collection2.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::DEPOSIT)
        end

        it 'returns collection ids where user has deposit access' do
          expect(described_class.collection_ids_for_deposit(ability: ability)).to match_array [collection.id, collection2.id]
        end
      end

      context 'when user has no access' do
        let(:ability) { Ability.new(user) }

        it 'returns empty array' do
          expect(described_class.collection_ids_for_deposit(ability: ability)).to match_array []
        end
      end
    end

    describe '.collection_ids_for_download_works' do
      let(:collection4) { Collection.create(id: 'col4', title: ['collection 4'], depositor: user2.ms_id, collection_type_gid: team_collection_type.gid) }

      context 'user has download works access through group and individual access' do
        before do
          collection4.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: collection4)
          collection4.reset_access_controls!

          collection.downloaders << user
          collection.downloaders_group.save
          collection.downloaders_group.reload

          collection2.managers << user
          collection2.managers_group.save
          collection2.managers_group.reload

          Hyrax::PermissionTemplateAccess.create(permission_template: collection3.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::EDIT_WORKS)

          Hyrax::PermissionTemplateAccess.create(permission_template: collection4.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS)
        end

        it 'returns collection ids where user has download works access' do
          expect(described_class.collection_ids_for_download_works(ability: ability)).to match_array [collection.id, collection2.id, collection3.id, collection4.id]
        end
      end

      context 'when user has no access' do
        let(:ability) { Ability.new(user) }

        it 'returns empty array' do
          expect(described_class.collection_ids_for_download_works(ability: ability)).to match_array []
        end
      end
    end

    describe '.collection_ids_for_view' do
      context 'user can view through group and individual access' do
        before do
          collection.viewers << user
          collection.viewers_group.save
          collection.viewers_group.reload

          Hyrax::PermissionTemplateAccess.create(permission_template: collection2.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::VIEW)
        end
        it 'returns collection ids where user has view access' do
          expect(described_class.collection_ids_for_view(ability: ability)).to match_array [collection.id, collection2.id]
        end
      end

      context 'when user has no access' do
        let(:ability) { Ability.new(user) }

        it 'returns empty array' do
          expect(described_class.collection_ids_for_view(ability: ability)).to match_array []
        end
      end
    end

    describe '.can_manage_any_collection?' do
      context 'user has manage access' do
        before do
          collection.managers << user
          collection.managers_group.save
          collection.managers_group.reload
        end
        it 'returns true when user has manage access to at least one collection' do
          expect(described_class.can_manage_any_collection?(ability: ability)).to be true
        end
      end

      context 'when user has no access' do
        let(:ability) { Ability.new(user) }

        it 'returns false' do
          expect(described_class.can_manage_any_collection?(ability: ability)).to be false
        end
      end
    end

    describe '.can_manage_any_admin_set?' do
      let(:admin_set)  { AdminSet.create(title: ['admin set 1']) }

      before do
        Hyrax::PermissionTemplate.create(source_id: admin_set.id)
      end

      context 'user has manage access' do
        before do
          Hyrax::PermissionTemplateAccess.create(permission_template: admin_set.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::MANAGE)
        end
        it 'returns true when user has manage access to at least one admin set' do
          expect(described_class.can_manage_any_admin_set?(ability: ability)).to be true
        end
      end

      context 'when user has no access' do
        let(:ability) { Ability.new(user) }

        it 'returns false' do
          expect(described_class.can_manage_any_admin_set?(ability: ability)).to be false
        end
      end
    end

    describe '.can_view_admin_show_for_any_collection?' do
      context 'user has editor access' do
        before do
          collection.editors << user
          collection.editors_group.save
          collection.editors_group.reload
        end

        it 'returns true when user has only edit works access to a collection' do
          expect(described_class.can_view_admin_show_for_any_collection?(ability: ability)).to be true
        end
      end

      context 'user has download works access' do
        before do
          collection.downloaders << user
          collection.downloaders_group.save
          collection.downloaders_group.reload
        end

        it 'returns true when user has only download works access to a collection' do
          expect(described_class.can_view_admin_show_for_any_collection?(ability: ability)).to be true
        end
      end

      context 'when user has no access' do
        let(:ability) { Ability.new(user) }

        it 'returns false' do
          expect(described_class.can_view_admin_show_for_any_collection?(ability: ability)).to be false
        end
      end
    end

    describe '.can_view_admin_show_for_any_admin set?' do
      let(:admin_set)  { AdminSet.create(title: ['admin set 1']) }

      before do
        Hyrax::PermissionTemplate.create(source_id: admin_set.id)
      end

      context 'user has edit works access' do
        before do
            Hyrax::PermissionTemplateAccess.create(permission_template: admin_set.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::EDIT_WORKS)
        end

        it 'returns true' do
          expect(described_class.can_view_admin_show_for_any_admin_set?(ability: ability)).to be true
        end
      end

      context 'user has download works access' do
        before do
            Hyrax::PermissionTemplateAccess.create(permission_template: admin_set.permission_template, agent_type: 'user', agent_id: user.ms_id, access: Hyrax::PermissionTemplateAccess::DOWNLOAD_WORKS)
        end

        it 'returns true' do
          expect(described_class.can_view_admin_show_for_any_admin_set?(ability: ability)).to be true
        end
      end

      context 'when user has no access' do
        let(:ability) { Ability.new(user) }

        it 'returns false' do
          expect(described_class.can_view_admin_show_for_any_admin_set?(ability: ability)).to be false
        end
      end
    end
  end
end
