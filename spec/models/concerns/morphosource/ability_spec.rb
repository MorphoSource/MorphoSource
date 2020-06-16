# frozen_string_literal: true

require 'cancan/matchers'
require 'rails_helper'

RSpec.describe 'Morphosource::Ability', type: :model do
  let(:user)    { User.create(email: 'email@email.com', password: 'password') }
  let(:ability) { Ability.new(user) }

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
          let(:edit_group)  { Role.create(name: 'edit_group') }
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
        let(:download_group)  { Role.create(name: 'download_group') }
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
end
