require 'rails_helper'
RSpec.describe Morphosource::CollectionTypes::MediaLists do

  describe 'SETTINGS' do

    it 'provides the correct configuration for projects' do
      media_list_collection_type = Hyrax::CollectionType.new(subject::SETTINGS)

      expect(media_list_collection_type.title).to eq("Media List")
      expect(media_list_collection_type.description).to eq("Assortment of media records. Media records can belong to multiple media lists. Multiple users can manage media lists.")
      expect(media_list_collection_type.machine_id).to eq("media_list")
      expect(media_list_collection_type.nestable).to be(false)
      expect(media_list_collection_type.discoverable).to be(true)
      expect(media_list_collection_type.sharable).to be(true)
      expect(media_list_collection_type.allow_multiple_membership).to be(true)
      expect(media_list_collection_type.require_membership).to be(false)
      expect(media_list_collection_type.assigns_workflow).to be(false)
      expect(media_list_collection_type.assigns_visibility).to be(false)
      expect(media_list_collection_type.share_applies_to_new_works).to be(false)
      expect(media_list_collection_type.brandable).to be(true)
      expect(media_list_collection_type.badge_color).to eq("#")
    end
  end
end
