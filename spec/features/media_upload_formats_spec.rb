
require 'rails_helper'

include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'update Media file formats', js: true, skip: "https://duldev.atlassian.net/browse/MR-520" do
  context 'a logged in user' do
    let(:user_attributes) do
      { email: 'test@example.com' }
    end
    let(:user) do
      User.new(user_attributes) { |u| u.save(validate: false) }
    end
    let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
    let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
    let(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    before do
      # Create a single action that can be taken
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

      # Grant the user access to deposit into the admin set.
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'user',
        agent_id: user.user_key,
        access: 'deposit'
      )
      login_as user
    end

    scenario do
      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"

      # If you generate more than one work uncomment these lines
      choose "payload_concern", option: "Media"
      click_button "Create work"

      # Add formats requirement
      expect(page).to have_content "File formats match selected media type"
      expect(page).to have_css('li#required-format.incomplete')

      # Test that accepted formats message changes as different media types are selected
      select('Image (*.tiff, *.png, *.dcm, etc.)', from: 'Media Type')
      click_link "Files" # switch tab
      expect(page).to have_content (Morphosource.image_formats.join(', '))

      click_link "Descriptions"
      select('Video (*.avi, *.mp4, *.mov, .etc.)', from: 'Media Type')
      click_link "Files"
      expect(page).to have_content (Morphosource.video_formats.join(', '))

      click_link "Descriptions"
      select('CT/MRI image series (multiple files of type *.tiff, *.png, *.dcm, *.zip, etc.)', from: 'Media Type')
      click_link "Files"
      expect(page).to have_content (Morphosource.ct_formats.join(', '))

      click_link "Descriptions"
      select('Photogrammetry image series (multiple files of type *.tiff, *.png, etc.)', from: 'Media Type')
      click_link "Files"
      expect(page).to have_content (Morphosource.photogrammetry_formats.join(', '))

      click_link "Descriptions"
      select('Mesh or point cloud (*.stl, *.ply, .etc, with optional associated texture or color file)', from: 'Media Type')
      click_link "Files"
      expect(page).to have_content (Morphosource.mesh_formats.join(', '))

    end
  end
end
