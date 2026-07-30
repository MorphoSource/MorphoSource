require 'rails_helper'

RSpec.describe 'catalog/_ms_catalog_search_form.html.erb', type: :view do
  def stub_view_helpers(current_user:, in_all_catalog: false)
    # These helpers are provided by Blacklight/Hyrax/Devise controllers at render
    # time, not declared on ActionView::Base, so partial-double verification would
    # reject the stubs without this wrapper.
    without_partial_double_verification do
      allow(view).to receive(:search_state).and_return(double(params_for_search: {}))
      allow(view).to receive(:current_search_parameters).and_return(nil)
      allow(view).to receive(:application_name).and_return('MorphoSource')
      allow(view).to receive(:catalog_search_form_action).and_return('/expected/search/path')
      allow(view).to receive(:current_user).and_return(current_user)
      allow(controller).to receive(:is_a?).and_call_original
      allow(controller).to receive(:is_a?).with(AllCatalogController).and_return(in_all_catalog)
    end
  end

  it 'sets the form action from catalog_search_form_action' do
    stub_view_helpers(current_user: nil)
    render
    page = Capybara::Node::Simple.new(rendered)
    expect(page).to have_selector('form#search-form-header[action="/expected/search/path"]')
  end

  describe 'the "All" dropdown option' do
    context 'when an admin is on the all catalog' do
      before { stub_view_helpers(current_user: instance_double(User, admin?: true), in_all_catalog: true) }

      it 'is rendered' do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).to have_selector("a.dropdown-item[data-search-option=\"#{all_search_path}\"]", text: 'All')
      end
    end

    context 'when an admin is on any other catalog' do
      before { stub_view_helpers(current_user: instance_double(User, admin?: true), in_all_catalog: false) }

      it 'is not rendered' do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).not_to have_selector("a.dropdown-item[data-search-option=\"#{all_search_path}\"]")
      end
    end

    context 'when a non-admin is on the all catalog' do
      before { stub_view_helpers(current_user: instance_double(User, admin?: false), in_all_catalog: true) }

      it 'is not rendered' do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).not_to have_selector("a.dropdown-item[data-search-option=\"#{all_search_path}\"]")
      end
    end

    context 'when there is no signed-in user' do
      before { stub_view_helpers(current_user: nil) }

      it 'is not rendered' do
        render
        page = Capybara::Node::Simple.new(rendered)
        expect(page).not_to have_selector("a.dropdown-item[data-search-option=\"#{all_search_path}\"]")
      end
    end
  end
end
