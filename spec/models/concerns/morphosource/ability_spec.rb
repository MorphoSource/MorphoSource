# frozen_string_literal: true

require 'cancan/matchers'
require 'rails_helper'

RSpec.describe 'Morphosource::Ability', type: :model do
  let(:user)            { User.create(email: 'email@email.com', password: 'password') }
  let(:ability)         { Ability.new(user) }
  let(:edit_group)      { Role.create(name: 'edit_group') }
  let(:download_group)  { Role.create(name: 'download_group') }
  let(:read_group)      { Role.create(name: 'download_group') }

  describe '#can?(:download, work)' do
    let(:work_id)   { work.id }
    let(:doc)       { SolrDocument.new(work.to_solr) }
    let(:id_test)   { ability.can? :download, work_id }
    let(:obj_test)  { ability.can? :download, work }
    let(:doc_test)  { ability.can? :download, doc }

    context 'the work is open' do
      let(:work)    { Media.create(title: ['open work'], visibility: 'open', fileset_accessibility: ['open']) }

      context 'the user is not registered' do
        before do
          allow(user).to receive(:groups).and_return([])
        end
        it 'returns false' do
          expect(id_test).to be(false)
          expect(obj_test).to be(false)
          expect(doc_test).to be(false)
        end
      end
      context 'the user is registered' do
        it 'returns true' do
          expect(id_test).to be(true)
          expect(obj_test).to be(true)
          expect(doc_test).to be(true)
        end
      end
    end
    context 'the work is private' do
      let(:work)  { Media.create(title: ['private work'], visibility: 'restricted') }
      context 'the user is an admin' do
        before do
          allow(user).to receive(:groups).and_return(['admin'])
        end
        it 'returns true' do
          expect(id_test).to be(true)
          expect(obj_test).to be(true)
          expect(doc_test).to be(true)
        end
      end
      context 'user has edit access' do
        context 'through a group' do
          before do
            edit_group.users << user
            edit_group.save
            work.edit_groups += [edit_group]
            work.save
          end
          it 'returns true' do
            expect(id_test).to be(true)
            expect(obj_test).to be(true)
            expect(doc_test).to be(true)
          end
        end
        context 'as an individual' do
          before do
            work.edit_users += [user]
            work.save
          end
          it 'returns true' do
            expect(id_test).to be(true)
            expect(obj_test).to be(true)
            expect(doc_test).to be(true)
          end
        end
      end
      context 'the user has individual access' do
        before do
          work.download_users += [user]
          work.save
        end
        it 'returns true' do
          expect(id_test).to be(true)
          expect(obj_test).to be(true)
          expect(doc_test).to be(true)
        end
      end
      context 'the user has group access' do
        before do
          download_group.users << user
          download_group.save
          work.download_groups += [download_group]
          work.save
        end
        it 'returns true' do
          expect(id_test).to be(true)
          expect(obj_test).to be(true)
          expect(doc_test).to be(true)
        end
      end
      context 'the user does not have access' do
        it 'returns false' do
          expect(id_test).to be(false)
          expect(obj_test).to be(false)
          expect(doc_test).to be(false)
        end
      end
    end
  end

  describe '#read_users' do
    context 'work is open' do
      let!(:work)  { Media.create(title: ['open work'], visibility: 'open') }
      context 'user does not have access' do
        it 'is empty' do
          expect(ability.read_users(work.id)).to match_array([])
        end
      end
      context 'user has edit access' do
        before do
          work.edit_users += [user]
          work.save
        end
        it 'is includes the user' do
          expect(ability.read_users(work.id)).to match_array([user.ms_id])
        end
      end
      context 'user has download access' do
        before do
          work.download_users += [user]
          work.save
        end
        it 'is includes the user' do
          expect(ability.read_users(work.id)).to match_array([user.ms_id])
        end
      end
      context 'user has read access' do
        before do
          work.read_users += [user]
          work.save
        end
        it 'is includes the user' do
          expect(ability.read_users(work.id)).to match_array([user.ms_id])
        end
      end
    end
  end

  describe '#read_groups' do
    context 'work is open' do
      let!(:work)  { Media.create(title: ['open work'], visibility: 'open') }
      it 'includes public' do
        expect(ability.read_groups(work.id)).to match_array(["public"])
      end
    end
    context 'work is restricted' do
      let!(:work)  { Media.create(title: ['restricted work'], visibility: 'restricted') }
      it 'is empty' do
        expect(ability.read_groups(work.id)).to match_array([])
      end
      context 'group has edit access' do
        before do
          work.edit_groups += [edit_group]
          work.save
        end
        it 'is includes the edit group' do
          expect(ability.read_groups(work.id)).to match_array([edit_group.name])
        end
      end
      context 'user group has download access' do
        before do
          work.download_groups += [download_group]
          work.save
        end
        it 'is includes the download group' do
          expect(ability.read_groups(work.id)).to match_array([download_group.name])
        end
      end
      context 'user group has read access' do
        before do
          work.read_groups += [read_group]
          work.save
        end
        it 'is includes the read group' do
          expect(ability.read_groups(work.id)).to match_array([read_group.name])
        end
      end
    end
  end

  describe '#can?(:read, work)' do
    let(:work_id)   { work.id }
    let(:doc)       { SolrDocument.new(work.to_solr) }
    let(:id_test)   { ability.can? :read, work_id }
    let(:obj_test)  { ability.can? :read, work }
    let(:doc_test)  { ability.can? :read, doc }

    context 'the work is open' do
      let(:work)    { Media.create(title: ['open work'], visibility: 'open', fileset_accessibility: ['open']) }

      context 'the user is not registered' do
        before do
          allow(user).to receive(:groups).and_return([])
        end
        it 'returns true' do
          expect(id_test).to be(true)
          expect(obj_test).to be(true)
          expect(doc_test).to be(true)
        end
      end
      context 'the user is registered' do
        it 'returns true' do
          expect(id_test).to be(true)
          expect(obj_test).to be(true)
          expect(doc_test).to be(true)
        end
      end
    end
    context 'the work is private' do
      let(:work)  { Media.create(title: ['private work'], visibility: 'restricted') }
      context 'the user is an admin' do
        before do
          allow(user).to receive(:groups).and_return(['admin'])
        end
        it 'returns true' do
          expect(id_test).to be(true)
          expect(obj_test).to be(true)
          expect(doc_test).to be(true)
        end
      end
      context 'user has edit access' do
        context 'through a group' do
          before do
            edit_group.users << user
            edit_group.save
            work.edit_groups += [edit_group]
            work.save
          end
          it 'returns true' do
            expect(id_test).to be(true)
            expect(obj_test).to be(true)
            expect(doc_test).to be(true)
          end
        end
        context 'as an individual' do
          before do
            work.edit_users += [user]
            work.save
          end
          it 'returns true' do
            expect(id_test).to be(true)
            expect(obj_test).to be(true)
            expect(doc_test).to be(true)
          end
        end
      end
      context 'the user has download access' do
        context 'through a group' do
          before do
            download_group.users << user
            download_group.save
            work.download_groups += [download_group]
            work.save
          end
          it 'returns true' do
            expect(id_test).to be(true)
            expect(obj_test).to be(true)
            expect(doc_test).to be(true)
          end
        end
        context 'as an individual' do
          before do
            work.download_users += [user]
            work.save
          end
          it 'returns true' do
            expect(id_test).to be(true)
            expect(obj_test).to be(true)
            expect(doc_test).to be(true)
          end
        end
      end
      context 'the user does not have access' do
        it 'returns false' do
          expect(id_test).to be(false)
          expect(obj_test).to be(false)
          expect(doc_test).to be(false)
        end
      end
    end
  end

  describe '#contributor?' do
    context 'user is not a contributor' do
      it 'returns false' do
        expect(ability.contributor?).to be(false)
      end
    end
    context 'user is a contributor' do
      before do
        allow(user).to receive(:groups).and_return(['contributor'])
      end
      it 'returns true' do
        expect(ability.contributor?).to be(true)
      end
    end
  end

  describe '#batch_submission_contributor?' do
    context 'user is not a batch_submission_contributor' do
      it 'returns false' do
        expect(ability.batch_submission_contributor?).to be(false)
      end
    end
    context 'user is a batch_submission_contributor' do
      before do
        allow(user).to receive(:groups).and_return(['batch_submission_contributor'])
      end
      it 'returns true' do
        expect(ability.batch_submission_contributor?).to be(true)
      end
    end
  end

  describe '#remote_file_submitter?' do
    context 'user is not a remote_file_submitter' do
      it 'returns false' do
        expect(ability.remote_file_submitter?).to be(false)
      end
    end
    context 'user is a remote_file_submitter' do
      before do
        allow(user).to receive(:groups).and_return(['remote_file_submitter'])
      end
      it 'returns true' do
        expect(ability.remote_file_submitter?).to be(true)
      end
    end
  end

  describe 'proxy_deposit_abilities' do
    let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }
    let(:owner)     { User.create(email: 'owner@email.com', password: 'password') }
    describe 'can? :transfer, String' do
      context 'media has only a depositor' do
        let!(:media) { Media.create(title: ['media'], depositor: depositor.ms_id) }
        let!(:ability) { Ability.new(depositor) }

        it 'allows the depositor to transfer the work' do
          expect(ability.can? :transfer, media.id).to be(true)
        end
      end
      context 'media has an owner' do
        let!(:media) { Media.create(title: ['media'], depositor: depositor.ms_id, owner: owner.ms_id) }
        let!(:owner_ability) { Ability.new(owner) }
        let!(:depositor_ability) { Ability.new(depositor) }
        it 'allows the owner to transfer the work' do
          expect(owner_ability.can? :transfer, media.id).to be(true)
        end
        it 'does not allow the depositor to transfer the work' do
          expect(depositor_ability.can? :transfer, media.id).to be(false)
        end
      end
      context 'user is an admin' do
        let!(:media) { Media.create(title: ['media'], depositor: depositor.ms_id) }
        let!(:admin)  { User.create(email: 'admin@email.com', password: 'password') }
        let(:admin_ability) { Ability.new(admin) }
        let(:admin_group) { Role.create(name: 'admin') }
        before do
          admin_group.users << admin
          admin_group.save
        end
        it 'allows the admin to transfer the work' do
          expect(admin_ability.can? :transfer, media.id).to be(true)
        end
      end
    end
  end

  describe 'temporary_link_abilities' do
    let(:other_user) { create(:user) }
    let(:managed_media) { create(:media, depositor: user.ms_id) }
    let(:unmanaged_media) { create(:media, depositor: other_user.ms_id) }
    let(:other_unmanaged_media) { create(:media, depositor: other_user.ms_id) }

    describe 'can? :destroy, TemporaryMediaAccessLink' do
      let(:user_temporary_link) { create(:temporary_media_access_link, user: user, media_id: unmanaged_media.id )} 
      let(:other_user_temporary_link) { create(:temporary_media_access_link, user: other_user, media_id: managed_media.id )}
      let(:third_temporary_link) { create(:temporary_media_access_link, user: other_user, media_id: unmanaged_media.id )}

      context 'user created the link but is not associated media data manager' do
        it 'user can' do
          expect(ability.can? :destroy, user_temporary_link).to be true
        end
      end

      context 'user did not create link but is associated media data manager' do
        it 'user can' do
          expect(ability.can? :destroy, other_user_temporary_link).to be true
        end
      end

      context 'user did not create link and is not associated media data manager' do
        it 'user cannot' do
          expect(ability.can? :destroy, third_temporary_link).to be false
        end
      end
    end

    describe 'can? :read, [ActiveFedora::Base, SolrDocument] without temporary link credentials' do
      context 'user is media data manager' do
        it 'user can read media' do
          managed_media.read_users += [user]
          managed_media.save
          expect(ability.can? :read, managed_media).to be true
        end
      end

      context 'user is not media data manager' do
        it 'user cannot read media' do
          expect(ability.can? :read, unmanaged_media).to be false
        end
      end
    end

    describe 'can? :read, [ActiveFedora::Base, SolrDocument] with temporary link credentials' do
      let(:temporary_link) { create(:temporary_media_access_link, user: user, media_id: unmanaged_media.id )} 

      before do
        ability.temporary_media_access_link = temporary_link
      end

      context 'user has temporary access credentials' do
        it 'user can access media' do
          expect(ability.can? :read, unmanaged_media).to be true
        end
      end

      context 'user has temporary access credentials, but not the right credentials for this media' do
        it 'user cannot access media' do
          expect(ability.can? :read, other_unmanaged_media).to be false
        end
      end
    end
  end
end
