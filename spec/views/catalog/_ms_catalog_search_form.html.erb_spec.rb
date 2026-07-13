require 'rails_helper'

RSpec.describe 'catalog/_ms_catalog_search_form.html.erb', type: :view do
  def stub_view_helpers(current_user:)
    # These helpers are provided by Blacklight/Hyrax/Devise controllers at render
    # time, not declared on ActionView::Base, so partial-double verification would
    # reject the stubs without this wrapper.
    without_partial_double_verification do
      allow(view).to receive(:search_state).and_return(double(params_for_search: {}))
      allow(view).to receive(:current_search_parameters).and_return(nil)
      allow(view).to receive(:application_name).and_return('MorphoSource')
      allow(view).to receive(:current_catalog_search_path).and_return('/expected/search/path')
      allow(view).to receive(:current_user).and_return(current_user)
    end
  end

  it 'sets the form action from current_catalog_search_path' do
    stub_view_helpers(current_user: nil)
    render
    page = Capybara::Node::Simple.new(rendered)
    expect(page).to have_selector('form#search-form-header[action="/expected/search/path"]')
  end

  describe 'the "All" dropdown option' do
    context 'when the user is an admin' do
      before { stub_view_helpers(current_user: instance_double(User, admin?: true)) }

      it 'is rendered' do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).to have_selector('a.dropdown-item[data-search-option="/catalog/all"]', text: 'All')
      end
    end

    context 'when the user is not an admin' do
      before { stub_view_helpers(current_user: instance_double(User, admin?: false)) }

      it 'is not rendered' do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).not_to have_selector('a.dropdown-item[data-search-option="/catalog/all"]')
      end
    end

    context 'when there is no signed-in user' do
      before { stub_view_helpers(current_user: nil) }

      it 'is not rendered' do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).not_to have_selector('a.dropdown-item[data-search-option="/catalog/all"]')
      end
    end
  end
end
