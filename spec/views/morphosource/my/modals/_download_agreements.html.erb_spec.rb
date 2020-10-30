require 'rails_helper'

RSpec.describe 'morphosource/my/modals/download_agreements.html.erb', type: :view do
  
  let(:agreement_uri) {'http://foobar.com/agreement_uri.pdf'}

  let(:expected_description) {"Permissive (Commercial Use Permitted, Encouraged But Not Required, 3D Printing Permitted)"}

	let(:work_solr_document) do
  	SolrDocument.new(id: '999',
                     title_tesim: ['My Title'],
                     creator_tesim: ['Doe, John', 'Doe, Jane'],
                     date_modified_dtsi: '2011-04-01',
                     has_model_ssim: ['Media'],
                     description_tesim: ['Lorem ipsum lorem ipsum.'],
                     keyword_tesim: ['bacon', 'sausage', 'eggs'],
                     rights_statement_tesim: ['http://example.org/rs/1'],
                     date_created_tesim: ['1984-01-02'],

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

  describe 'render the agreement modal' do

		before do	  
      allow(media_presenter).to receive(:media).and_return(media)
      render 'morphosource/my/modals/download_agreements'
  	end

    it 'contains the agreement modal id, with checkbox, and disabled button' do
      expect(page).to have_selector('[id="downloadAgreementsModal"]')
      expect(page).to have_selector('input[type="checkbox"][id="modal-agree"]')
      expect(page).to have_selector('input[type="button"][id="modal-download"][disabled="disabled"]')
    end
  end
end
