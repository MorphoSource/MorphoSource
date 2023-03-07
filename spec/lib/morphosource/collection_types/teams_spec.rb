require 'rails_helper'
RSpec.describe Morphosource::CollectionTypes::Teams do

  describe 'SETTINGS' do

    it 'provides the correct configuration for teams' do
      team_collection_type = Hyrax::CollectionType.new(subject::SETTINGS)

      expect(team_collection_type.title).to eq("Team")
      expect(team_collection_type.description).to eq("Group of users belonging to the same institution, organization, department, collection, or lab. Teams can manage projects collectively.")
      expect(team_collection_type.machine_id).to eq("team")
      expect(team_collection_type.nestable).to be(true)
      expect(team_collection_type.discoverable).to be(true)
      expect(team_collection_type.sharable).to be(true)
      expect(team_collection_type.allow_multiple_membership).to be(true)
      expect(team_collection_type.require_membership).to be(false)
      expect(team_collection_type.assigns_workflow).to be(false)
      expect(team_collection_type.assigns_visibility).to be(true)
      expect(team_collection_type.share_applies_to_new_works).to be(true)
      expect(team_collection_type.brandable).to be(true)
      expect(team_collection_type.badge_color).to eq("#FF861F")
    end
  end
end
