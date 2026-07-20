require 'rails_helper'

RSpec.describe 'morphosource/my/cart/_all_downloadable_items_hidden.html.erb', type: :view do
  let(:on_page_item)  { CartItem.new(id: 1, work_id: 'onpage1') }
  let(:off_page_item) { CartItem.new(id: 2, work_id: 'offpage1') }

  let(:off_page_doc) do
    SolrDocument.new(id: 'offpage1', title_tesim: ['Off Page'], has_model_ssim: ['Media'])
  end

  let(:page) { Capybara::Node::Simple.new(rendered) }

  before do
    allow(view).to receive(:solr_docs_find).with(['offpage1']).and_return('offpage1' => off_page_doc)
    allow(view).to receive(:current_ability).and_return(double)

    assign(:unrestricted_items, [on_page_item, off_page_item])
    assign(:paginated_unrestricted_items, [on_page_item])

    render
  end

  it 'renders agreement data for items not on the current page' do
    expect(page).to have_selector('div[data-item-id="2"]')
  end

  it 'does not duplicate agreement data for items already on the current page' do
    expect(page).not_to have_selector('div[data-item-id="1"]')
  end

  it 'renders inside a hidden wrapper so it never displays visually' do
    expect(page).to have_selector('table#all-downloadable-items-hidden.hide')
  end

  it 'looks up off-page documents in a single batched call, not one per item' do
    expect(view).to have_received(:solr_docs_find).with(['offpage1']).once
  end
end
