require 'rails_helper'

RSpec.describe 'hyrax/media/_form_media_edit.html.erb', type: :view do
  let(:doi)       { nil }
  let(:solr_doc)  { SolrDocument.new(id: '999', title_tesim: ['Test'], has_model_ssim: ['Media']) }
  let(:ability)   { double('ability') }
  let(:presenter) { instance_double(Hyrax::MediaPresenter) }
  let(:user)      { FactoryBot.build(:user) }
  let(:page)      { Capybara::Node::Simple.new(rendered) }

  before do
    # Stub all nested partials and modal renders so we only test the outer div.
    stub_template 'hyrax/media/_guts4form.html.erb'                             => ''
    stub_template 'hyrax/media/_modal_new_physical_object.html.erb'             => ''
    stub_template 'hyrax/media/_modal_select_physical_object.html.erb'          => ''
    stub_template 'hyrax/media/_modal_select_parent_media.html.erb'             => ''
    stub_template 'hyrax/media/_modal_select_parent_media_new_processing_event.html.erb' => ''

    assign(:presenter, presenter)
    # @form.model_name.param_key is evaluated as an argument to simple_form_for even when stubbed.
    assign(:form, double('form', model_name: double('model_name', param_key: 'media'), errors: double(any?: false)))

    # Skip the imaging event and processing event branches.
    allow(presenter).to receive(:doi).and_return(doi)
    allow(presenter).to receive(:imaging_event).and_return(nil)
    allow(presenter).to receive(:processing_events_data).and_return(nil)
    allow(presenter).to receive(:id).and_return('999')

    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:can?).and_return(false)
    # Stub simple_form_for so form objects are not required.
    allow(view).to receive(:simple_form_for)
  end

  context 'when media has no DOI' do
    it 'does not render data-doi-locked on the edit_media div' do
      render
      expect(page).not_to have_css('.edit_media[data-doi-locked]')
    end
  end

  context 'when media has a DOI' do
    let(:doi) { ['10.1234/test'] }

    context 'and current user is not admin' do
      before { allow(user).to receive(:admin?).and_return(false) }

      it 'renders data-doi-locked="true" on the edit_media div' do
        render
        expect(page).to have_css('.edit_media[data-doi-locked="true"]')
      end
    end

    context 'and current user is admin' do
      before { allow(user).to receive(:admin?).and_return(true) }

      it 'does not render data-doi-locked on the edit_media div' do
        render
        expect(page).not_to have_css('.edit_media[data-doi-locked]')
      end
    end
  end
end
