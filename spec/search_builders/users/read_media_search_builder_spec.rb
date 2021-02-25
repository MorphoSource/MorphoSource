require 'rails_helper'

# frozen_string_literal: true
RSpec.describe Morphosource::Users::ReadMediaSearchBuilder do
  let(:user)      { User.create(email: 'registered@email.com', password: 'password') }
  let(:ability)   { ::Ability.new(user) }
  let(:scope)     { double(blacklight_config: CatalogController.blacklight_config, current_ability: ability) }

  subject { described_class.new(scope) }

  describe 'models' do
    it 'is media' do
      expect(subject.models).to match_array([Media])
    end
  end

  describe 'read_grants_filters' do
    let(:viewer_group)    { 'test_viewers' }
    let(:download_group)  { 'test_downloaders' }
    before do
      allow(ability).to receive(:user_groups).and_return([viewer_group, download_group])
    end

    it 'filters media with with read access granted to the user through a group' do
      expect(subject.send(:read_grants_filters)).to match_array(["read_access_group_ssim:#{viewer_group}", "download_access_group_ssim:#{download_group}"])
    end
  end

  describe 'discovery_permissions' do
    it 'is download and read' do
      expect(subject.discovery_permissions).to match_array(['download','read'])
    end
  end
end
