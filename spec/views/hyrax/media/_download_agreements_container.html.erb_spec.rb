require 'rails_helper'

RSpec.describe 'hyrax/media/_download_agreements_container.html.erb', type: :view do
  
  let(:agreement_uri) {'http://foobar.com/agreement_uri.pdf'}

  let(:expected_description) {"Permissive (Commercial Use Permitted, Encouraged But Not Required, 3D Printing Permitted)"}

	let(:work_solr_document) do
  	SolrDocument.new(id: '999',
                     title_tesim: ['My Title'],
                     has_model_ssim: ['Media'],
                    morphosource_use_agreement_type_tesim: ['Permissive'], 
                    permits_commercial_use_tesim: ['CommercialUsePermitted'],
                    required_archival_of_published_derivatives_tesim: ['EncouragedButNotRequired'],
                    permits_3d_use_tesim: ['3DPrintingPermitted'],
                    agreement_uri_tesim: [agreement_uri]
                     )
  end

  let(:media)     { Media.new(id: '999', title: ["My Title"], visibility: 'open', fileset_visibility: [''])}

  let(:ability) { double }
  let(:media_presenter) do
    Hyrax::MediaPresenter.new(work_solr_document, ability, request)
  end

  let(:page) { Capybara::Node::Simple.new(rendered) }

  describe 'Hidden download_agreements container for building the agreement modal' do

		before do	  
      allow(media_presenter).to receive(:media).and_return(media)
      #render :file => 'hyrax/media/showcase', presenter: media_presenter
      render 'hyrax/media/download_agreements_container', presenter: media_presenter
  	end

		it 'contains proper selectors and content ' do
      expect(page).to have_css('.agreements')
      expect(page).to have_selector('[id="media-page-download-agreements"][class="download-agreements hide"]')
      expect(page).to have_selector('div[class="agreements"][data-item-id="CURRENT"]')
      expect(page).to have_selector('div[data-field="media_doc_id"][data-value="999"]')
      expect(page).to have_selector('div[data-field="agreement_uri"]')
			#expect(page).to have_content "Abc (Def, Ghi, Jkl)"
		end

    it 'contains the agreement description and link' do
      expect(page).to have_selector('div[data-field="agreement_description"][data-value="'+expected_description+'"]')
      expect(page).to have_selector('a[class="aup-link"]')
    end

    it 'contains user added custom agreement link' do
      expect(page).to have_link 'Depositor-Supplied Additional Usage Agreement'
    end

  end
end
