require 'rails_helper'

RSpec.describe 'records/edit_fields/_modality.html.erb', type: :view do
  let(:work) { Device.new }
  let(:form) { Hyrax::DeviceForm.new(work, nil, controller) }
  let(:form_template) do
    %(
      <%= simple_form_for [main_app, @form] do |f| %>
        <%= render "records/edit_fields/modality", f: f, key: 'modality' %>
      <% end %>
    )
  end

  before do
    assign(:form, form)
    render inline: form_template
  end

  it 'has a country drop down select' do
    expect(rendered).to have_field('Modality')
    expect(rendered).to have_selector('//select')
    expect(rendered).to have_selector('//option', :text => 'Photography')
  end
end