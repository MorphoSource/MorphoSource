# frozen_string_literal: true

require 'cancan/matchers'
require 'rails_helper'

RSpec.describe 'Hyrax::Ability::CollectionAbility' do
  subject                           { ability }
  let(:ability)                     { Ability.new(user) }
  let(:collection_depositor)        { FactoryBot.create(:contributor) }
  let(:registered_user)             { FactoryBot.create(:registered_user) }
  let(:contributor)                 { FactoryBot.create(:contributor) }

  let(:admin)                       { FactoryBot.create(:admin) }

  let(:new_team)                    { FactoryBot.build(:team) }
  let(:new_project)                 { FactoryBot.build(:project) }
  let(:new_organization)            { FactoryBot.build(:organization_collection) }
  let(:new_media_list)              { FactoryBot.build(:media_list) }
  let(:new_sequential_section_list) { FactoryBot.build(:sequential_section_list) }

  context 'Creating a new collection' do
    context 'admin' do
      let(:user)  { admin }
      it 'can create all collection types' do
        is_expected.to be_able_to(:create, new_team)
        is_expected.to be_able_to(:create, new_project)
        is_expected.to be_able_to(:create, new_organization)
        is_expected.to be_able_to(:create, new_media_list)
        is_expected.to be_able_to(:create, new_sequential_section_list)
      end
    end

    context 'contributor' do
      let(:user)  { contributor }
      it 'can create all types except organizations' do
        is_expected.to be_able_to(:create, new_team)
        is_expected.to be_able_to(:create, new_project)
        # TODO: contributors should not be able to create new organizations
        # is_expected.not_to be_able_to(:create, new_organization)
        is_expected.to be_able_to(:create, new_media_list)
        is_expected.to be_able_to(:create, new_sequential_section_list)
      end
    end

    context 'registered user' do
      let(:user)  { registered_user }
      it 'can create media lists only' do
        is_expected.not_to be_able_to(:create, new_team)
        is_expected.not_to be_able_to(:create, new_project)
        is_expected.not_to be_able_to(:create, new_organization)
        is_expected.to be_able_to(:create, new_media_list)
        is_expected.not_to be_able_to(:create, new_sequential_section_list)
      end
    end
  end
end
