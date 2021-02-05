require 'rails_helper'

# frozen_string_literal: true
RSpec.describe Morphosource::Users::EditObjectsSearchBuilder do
  let(:user)      { User.create(email: 'registered@email.com', password: 'password') }
  let(:ability)   { ::Ability.new(user) }
  let(:scope)     { double(blacklight_config: CatalogController.blacklight_config, current_ability: ability) }

  subject { described_class.new(scope) }

  describe 'models' do
    it 'is specimen and cho' do
      expect(subject.models).to match_array([BiologicalSpecimen, CulturalHeritageObject])
    end
  end

  describe 'discovery_permissions' do
    it 'is edit' do
      expect(subject.discovery_permissions).to eq(['edit'])
    end
  end
end
