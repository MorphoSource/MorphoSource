require 'rails_helper'

RSpec.describe 'records/edit_fields/_country.html.erb', type: :view do
  let(:work) { Institution.new }
  let(:form) { Hyrax::InstitutionForm.new(work, nil, controller) }
  let(:form_template) do
    %(
      <%= simple_form_for [main_app, @form] do |f| %>
        <%= render "records/edit_fields/country", f: f, key: 'country' %>
      <% end %>
    )
  end

  before do
    assign(:form, form)
    render inline: form_template
  end

  it 'has a country drop down select' do
    expect(rendered).to have_field('Country')
    expect(rendered).to have_selector('//select')
    expect(rendered).to have_selector('//option', :text => 'Mexico')
  end
end