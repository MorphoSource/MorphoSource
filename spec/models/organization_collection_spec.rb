# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OrganizationCollection, type: :model do
  let(:organization)  { FactoryBot.create(:organization_collection) }

  describe 'collection_type' do
    it 'has the organization collection type' do
      expect(described_class.collection_type).to eq(organization_collection_type)
      expect(subject.collection_type).to eq(organization_collection_type)
      expect(subject.human_readable_type).to eq('Organization')
    end
  end
end
