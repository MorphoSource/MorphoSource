# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::UserProfilePresenter do
  let(:user)         { User.create(email: 'profileuser@example.com', password: 'password') }
  let(:current_user) { User.create(email: 'viewer@example.com', password: 'password') }
  let(:ability)      { ::Ability.new(current_user) }

  subject { described_class.new(user, ability) }

  describe '#managed_organization_count' do
    context 'when the user manages an organization' do
      let(:org_doc) { FactoryBot.create(:organization_collection_document) }

      before do
        Role.create(name: "#{org_doc.id}_managers", users: [user])
        user.reload
      end

      it 'returns 1' do
        expect(subject.managed_organization_count).to eq(1)
      end
    end

    context 'when the user manages no organizations' do
      it 'returns 0' do
        expect(subject.managed_organization_count).to eq(0)
      end
    end

    context 'when the user manages multiple organizations' do
      let(:org_doc_1) { FactoryBot.create(:organization_collection_document) }
      let(:org_doc_2) { FactoryBot.create(:organization_collection_document) }

      before do
        Role.create(name: "#{org_doc_1.id}_managers", users: [user])
        Role.create(name: "#{org_doc_2.id}_managers", users: [user])
        user.reload
      end

      it 'returns the correct count' do
        expect(subject.managed_organization_count).to eq(2)
      end
    end
  end
end
