require 'rails_helper'

RSpec.describe 'morphosource/admin/appearance/modals/show.html.erb', type: :view do
  before do
    view.extend Morphosource::AppearanceHelper
    assign(:form, Morphosource::Forms::Admin::Modal.new)
    render
  end

  # Parsed as HTML5 because a nested <form> closes the outer form in browsers
  it 'submits every modal setting with the form' do
    form = Nokogiri::HTML5(rendered).at_css('#modal-form')
    field_names = form.css('[name^="admin_modal["]').map { |field| field['name'] }

    expected = Morphosource::Forms::Admin::Modal::SETTINGS.map { |setting| "admin_modal[#{setting}]" }
    expect(field_names).to include(*expected)
  end
end
