# frozen_string_literal: true
require 'rails_helper'
require 'dry/container/stub'

RSpec.describe Morphosource::Transactions::Taxonomy::WorkCreate, :clean_repo do
  subject(:tx)     { described_class.new }
  let(:change_set) { Hyrax::ChangeSet.for(resource) }
  let(:depositor) { FactoryBot.create(:user) }
  let(:resource)   { build(:taxonomy_resource, depositor: depositor.user_key) }
  let(:default_admin_set_id) { Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id }

  context 'default hyrax work create transaction behavior' do
    describe '#call' do
      it 'is a success' do
        # byebug
        expect(tx.call(change_set)).to be_success
      end

      it 'wraps a saved work' do
        expect(tx.call(change_set).value!).to be_persisted
      end

      it 'sets the default admin set' do
        expect(tx.call(change_set).value!)
          .to have_attributes admin_set_id: default_admin_set_id
      end

      context 'when an admin set is already assigned to the work' do
        let(:admin_set) { valkyrie_create(:hyrax_admin_set) }
        let(:resource) { build(:taxonomy_resource, admin_set_id: admin_set.id, depositor: depositor.user_key) }

        it 'keeps the existing admin set' do
          expect(tx.call(change_set).value!)
            .to have_attributes admin_set_id: admin_set.id
        end
      end

      context 'when providing a depositor' do
        let(:user) { FactoryBot.create(:user) }

        it 'sets the given user as the depositor' do
          tx.with_step_args('change_set.set_user_as_depositor' => { user: user })

          expect(tx.call(change_set).value!)
            .to have_attributes depositor: user.user_key
        end
      end

      context 'when providing a proxy_depositor' do
        let(:user) { FactoryBot.create(:user) }
        let(:on_behalf_of) { FactoryBot.create(:user) }
        let(:resource) { build(:taxonomy_resource, depositor: user.user_key) }

        it 'sets the given user as depositor, old depositor as proxy_depositor' do
          tx.with_step_args('work_resource.change_depositor' => { user: on_behalf_of })

          expect(tx.call(change_set).value!)
            .to have_attributes(
              proxy_depositor: user.user_key,
              depositor: on_behalf_of.user_key
            )
        end
      end
    end
  end

  context 'taxonomy-specific work create transaction behavior' do
    # todo add tests here
  end
end
