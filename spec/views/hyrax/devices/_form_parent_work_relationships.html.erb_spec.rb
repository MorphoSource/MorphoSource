require 'rails_helper'

RSpec.describe 'hyrax/devices/_form_parent_work_relationships.html.erb', type: :view do
  let(:organization) do
    double('Organization', id: 'org-123', title: ['Sample Organization'])
  end
  let(:work) do
    FactoryBot.build(:device_resource, organization_id: ['org-123'])
  end
  let(:form) { DeviceResourceForm.new(work) }
  let(:page) do
    form.controller = controller
    assign(:organization, organization)
    assign(:form, form)
    render inline: <<~ERB
      <%= simple_form_for [main_app, @form] do |f| %>
        <%= render 'hyrax/devices/form_parent_work_relationships', f: f %>
      <% end %>
    ERB
    Capybara::Node::Simple.new(rendered)
  end

  it 'renders the selected organization label and hidden id field' do
    expect(page).to have_selector('#selected-device-organization-label', text: 'Sample Organization')
  end
end
