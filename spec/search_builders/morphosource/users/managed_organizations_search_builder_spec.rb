# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Users::ManagedOrganizationsSearchBuilder do
  let(:user)         { User.create(email: 'manager@example.com', password: 'password') }
  let(:ability)      { ::Ability.new(user) }
  let(:scope)        { double(blacklight_config: OrganizationsCatalogController.blacklight_config, current_ability: ability, user: user) }
  let(:repository)   { Blacklight::Solr::Repository.new(OrganizationsCatalogController.blacklight_config) }

  subject { described_class.new(scope) }

  describe '#models' do
    it 'is OrganizationCollection' do
      expect(subject.send(:models)).to match_array([OrganizationCollection])
    end
  end

  describe '#blacklight_config' do
    it 'uses OrganizationsCatalogController blacklight config' do
      expect(subject.blacklight_config).to eq(OrganizationsCatalogController.blacklight_config)
    end
  end

  describe 'processor chain' do
    it 'includes filter_by_managing_user' do
      expect(described_class.default_processor_chain).to include(:filter_by_managing_user)
    end
  end

  describe '#filter_by_managing_user' do
    let(:org_doc) { FactoryBot.create(:organization_collection_document) }

    before do
      Role.create(name: "#{org_doc.id}_managers", users: [user])
      user.reload
    end

    it 'returns managed organizations from Solr' do
      results = repository.search(subject.query)
      expect(results.response['numFound']).to eq(1)
    end

    it 'does not return organizations not managed by the user' do
      FactoryBot.create(:organization_collection_document) # unmanaged org
      results = repository.search(subject.query)
      expect(results.response['numFound']).to eq(1)
    end
  end
end
