require 'rails_helper'

RSpec.describe 'morphosource/batch_edits/_download_all.html.erb', type: :view do
  let(:page) { Capybara::Node::Simple.new(rendered) }

  before do
    render
  end

  it 'renders a plain Download All button, not its own form' do
    expect(page).to have_selector('button#download-all[type="button"]', text: 'Download All')
    expect(page).not_to have_selector('form#download-all-form')
  end

  it 'still renders the Clear Cart form' do
    expect(page).to have_selector('form input#clear-cart[type="submit"]')
  end
end
