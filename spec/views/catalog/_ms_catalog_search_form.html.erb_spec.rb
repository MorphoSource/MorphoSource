require 'rails_helper'

RSpec.describe 'catalog/_ms_catalog_search_form.html.erb', type: :view do
  before do
    # These helpers are provided by Blacklight/Hyrax controllers at render time,
    # not declared on ActionView::Base, so partial-double verification would reject
    # the stubs without this wrapper.
    without_partial_double_verification do
      allow(view).to receive(:search_state).and_return(double(params_for_search: {}))
      allow(view).to receive(:current_search_parameters).and_return(nil)
      allow(view).to receive(:application_name).and_return('MorphoSource')
      allow(view).to receive(:current_catalog_search_path).and_return('/expected/search/path')
    end
  end

  it 'sets the form action from current_catalog_search_path' do
    render
    page = Capybara::Node::Simple.new(rendered)
    expect(page).to have_selector('form#search-form-header[action="/expected/search/path"]')
  end
end
