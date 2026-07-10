require 'rails_helper'

RSpec.describe 'morphosource/batch_edits/_download_all.html.erb', type: :view do
  let(:page) { Capybara::Node::Simple.new(rendered) }

  before do
    render
  end

  it 'submits the Download All form as a POST with no item ids' do
    expect(page).to have_selector('form#download-all-form[action="/download_items"][method="post"]')
    expect(page).not_to have_selector('form#download-all-form input[name="item_id"]')
    expect(page).not_to have_selector('form#download-all-form input[name="batch_download_ids[]"]')
  end

  it 'carries hidden fields for usage, usage_list, and recaptcha response for the JS to populate before submit' do
    expect(page).to have_selector('form#download-all-form input#download_all_usage[type="hidden"]', visible: false)
    expect(page).to have_selector('form#download-all-form input#download_all_usage_list[type="hidden"]', visible: false)
    expect(page).to have_selector('form#download-all-form input#download_all_recaptcha_response[type="hidden"][name="g-recaptcha-response"]', visible: false)
  end

  it 'still renders the Clear Cart form' do
    expect(page).to have_selector('form input#clear-cart[type="submit"]')
  end
end
