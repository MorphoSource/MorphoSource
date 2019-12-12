require 'rails_helper'

RSpec.describe 'hyrax/base/_representative_media.html.erb', type: :view do
	let(:work_solr_document) do
  	SolrDocument.new(id: '999',
                     title_tesim: ['My Title'],
                     creator_tesim: ['Doe, John', 'Doe, Jane'],
                     date_modified_dtsi: '2011-04-01',
                     has_model_ssim: ['Media'],
                     depositor_tesim: depositor.user_key,
                     description_tesim: ['Lorem ipsum lorem ipsum.'],
                     keyword_tesim: ['bacon', 'sausage', 'eggs'],
                     rights_statement_tesim: ['http://example.org/rs/1'],
                     date_created_tesim: ['1984-01-02'])
  end

  let(:file_set_solr_document) do
    SolrDocument.new(id: '123',
                     title_tesim: ['My FileSet'],
                     depositor_tesim: depositor.user_key)
  end

  let(:ability) { double }

  let(:presenter) do
    Hyrax::WorkShowPresenter.new(work_solr_document, ability, request)
  end

  let(:representative_presenter) do
    Hyrax::FileSetPresenter.new(file_set_solr_document, ability)
  end

  let(:page) { Capybara::Node::Simple.new(rendered) }

  let(:request) { double('request', host: 'test.host') }

  let(:depositor) do
    FactoryBot.build(:user)
  end

  describe 'UniversalViewer iframe presence/absence' do
  	context 'when representative presenter and id present' do
  		before do
	  		allow(presenter).to receive(:representative_presenter).and_return(representative_presenter)
	  		allow(presenter).to receive(:representative_id).and_return('123')
	  	end

  		context 'when viewer is defined' do
  			it 'renders UniversalViewer iframe' do
  				render 'hyrax/base/representative_media', presenter: presenter, viewer: true
  				expect(page).to have_selector 'iframe'
  			end
  		end

  		context 'when viewer is not defined' do
  			it 'omits UniversalViewer iframe' do
  				render 'hyrax/base/representative_media', presenter: presenter
  				expect(page).not_to have_selector 'iframe'
  			end
  		end
  	end

  	context 'when representative presenter and id not present' do
  		before do
	  		render 'hyrax/base/representative_media', presenter: presenter
	  	end

  		it 'omits UniversalViewer iframe' do
  			expect(page).not_to have_selector 'iframe'
  		end
  	end
  end
end