require 'rails_helper'
RSpec.describe Morphosource::CollectionTypes::Organizations do

  describe 'SETTINGS' do

    it 'provides the correct configuration for projects' do
      project_collection_type = Hyrax::CollectionType.new(subject::SETTINGS)

      expect(project_collection_type.title).to eq('Organization')
      expect(project_collection_type.description).to eq('Facilitates management of objects, devices, and media for affiliated users.')
      expect(project_collection_type.machine_id).to eq('organization')
      expect(project_collection_type.nestable).to be(true)
      expect(project_collection_type.discoverable).to be(true)
      expect(project_collection_type.sharable).to be(true)
      expect(project_collection_type.allow_multiple_membership).to be(true)
      expect(project_collection_type.require_membership).to be(false)
      expect(project_collection_type.assigns_workflow).to be(false)
      expect(project_collection_type.assigns_visibility).to be(false)
      expect(project_collection_type.share_applies_to_new_works).to be(true)
      expect(project_collection_type.brandable).to be(true)
      expect(project_collection_type.badge_color).to eq('#329a43')
    end
  end
end
