require 'cancan/matchers'
require 'rails_helper'

# Admins have all Hyrax::CollectionType abilities
# Contributors are able to create new collections but have no other abilities
# Registered users do not have any Hyrax::CollectionType abilities

RSpec.describe 'Hyrax::Ability::CollectionAbility' do
  subject       { ability }
  let(:ability) { Ability.new(user) }

  context 'when admin user' do
    let(:user)  { FactoryBot.create(:admin) }

    context 'Hyrax::CollectionType' do
      it 'allows all abilities' do
        is_expected.to be_able_to(:manage, Hyrax::CollectionType)
        is_expected.to be_able_to(:create, Hyrax::CollectionType)
        is_expected.to be_able_to(:edit, Hyrax::CollectionType)
        is_expected.to be_able_to(:update, Hyrax::CollectionType)
        is_expected.to be_able_to(:destroy, Hyrax::CollectionType)
        is_expected.to be_able_to(:create_collection_of_type, Hyrax::CollectionType)
      end
    end
  end

  context 'when contributor user' do
    let(:user)  { FactoryBot.create(:contributor) }

    context 'Hyrax::CollectionType' do
      it 'allows only creating new collections' do
        is_expected.not_to be_able_to(:manage, Hyrax::CollectionType)
        is_expected.not_to be_able_to(:create, Hyrax::CollectionType)
        is_expected.not_to be_able_to(:edit, Hyrax::CollectionType)
        is_expected.not_to be_able_to(:update, Hyrax::CollectionType)
        is_expected.not_to be_able_to(:destroy, Hyrax::CollectionType)
        is_expected.to be_able_to(:create_collection_of_type, Hyrax::CollectionType)
      end
    end
  end

  context 'when registered user' do
    let(:user)  { FactoryBot.create(:registered_user) }

    context 'Hyrax::CollectionType' do
      it 'does not allow any abilities' do
        is_expected.not_to be_able_to(:manage, Hyrax::CollectionType)
        is_expected.not_to be_able_to(:create, Hyrax::CollectionType)
        is_expected.not_to be_able_to(:edit, Hyrax::CollectionType)
        is_expected.not_to be_able_to(:update, Hyrax::CollectionType)
        is_expected.not_to be_able_to(:destroy, Hyrax::CollectionType)
        is_expected.not_to be_able_to(:create_collection_of_type, Hyrax::CollectionType)
      end
    end
  end
end