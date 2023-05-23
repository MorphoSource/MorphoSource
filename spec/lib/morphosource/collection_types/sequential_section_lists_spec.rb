require 'rails_helper'
RSpec.describe Morphosource::CollectionTypes::SequentialSectionLists do

  describe 'SETTINGS' do

    it 'provides the correct configuration for projects' do
      sequential_section_list_collection_type = Hyrax::CollectionType.new(subject::SETTINGS)

      expect(sequential_section_list_collection_type.title).to eq("Sequential Section List")
      expect(sequential_section_list_collection_type.description).to eq("Assortment of media records created from a single object. Multiple users can manage sequential section lists.")
      expect(sequential_section_list_collection_type.machine_id).to eq("sequential_section_list")
      expect(sequential_section_list_collection_type.nestable).to be(false)
      expect(sequential_section_list_collection_type.discoverable).to be(true)
      expect(sequential_section_list_collection_type.sharable).to be(true)
      expect(sequential_section_list_collection_type.allow_multiple_membership).to be(true)
      expect(sequential_section_list_collection_type.require_membership).to be(false)
      expect(sequential_section_list_collection_type.assigns_workflow).to be(false)
      expect(sequential_section_list_collection_type.assigns_visibility).to be(false)
      expect(sequential_section_list_collection_type.share_applies_to_new_works).to be(false)
      expect(sequential_section_list_collection_type.brandable).to be(true)
      expect(sequential_section_list_collection_type.badge_color).to eq("#059aad")
    end
  end
end