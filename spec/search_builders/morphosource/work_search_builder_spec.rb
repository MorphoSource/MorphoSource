require 'rails_helper'

RSpec.describe Morphosource::WorkSearchBuilder do
  let(:params) do
    {"locale"=>"en", "controller"=>"hyrax/media", "id"=>"test_id"}
  end

  let(:user)    { FactoryBot.create(:user) }
  let(:ability) { Ability.new(user) }
  let(:scope)   { double('scope', blacklight_config: CatalogController.blacklight_config, current_ability: ability, params: {}) }
  let(:builder) { described_class.new(scope).with(params) }

  describe '#discovery_permissions' do
    subject { builder.discovery_permissions }

    it { is_expected.to eq %w[edit discover download read] }
  end
end
