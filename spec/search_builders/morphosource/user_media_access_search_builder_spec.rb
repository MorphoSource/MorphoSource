require 'rails_helper'

# frozen_string_literal: true
RSpec.describe Morphosource::UserMediaAccessSearchBuilder do

  let(:user)   { User.create(email:'registered@email.com', password: 'password') }

  let(:ability) { ::Ability.new(user) }
  let(:scope)   { double(blacklight_config: CatalogController.blacklight_config, current_ability: ability) }

  let(:access)  { :read }

  let(:builder) { described_class.new(scope).with_access(access) }

  let(:config) { CollectionsCatalogController.blacklight_config }

  subject { Blacklight::Solr::Repository.new(config).search(builder) }

  describe '#models' do
    its(:models) { is_expected.to eq([Media]) }
  end

  describe '#discovery_permissions' do
    context 'when access is read' do
      let(:access) { :read }

      its(:discovery_permissions) { is_expected.to eq %w[read] }
    end

    context 'when access is edit' do
      let(:access) { :edit }

      its(:discovery_permissions) { is_expected.to eq %w[edit] }
    end
  end

  describe 'testing' do
    let!(:media) { Media.create(title: ['media'], visibility: 'open') }

    it 'returns the media' do
      expect(subject).to eq([])
    end
  end
end
