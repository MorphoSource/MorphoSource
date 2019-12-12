require 'rails_helper'

RSpec.describe 'hyrax/devices/_attribute_rows.html.erb', type: :view do
	let(:url) { "http://example.com" }
	let(:ability) { double }
	let(:work) do
		Device.new({
        title: ['XTekCT 100'],
        creator: ['Nikon'],
        modality: ['MedicalXRayComputedTomography'],
        facility: ['Duke SMIF'],
        description: ['A sample description']
    })
	end
	let(:solr_document) { SolrDocument.new(work.to_solr) }
  let(:presenter) { Hyrax::DevicePresenter.new(solr_document, ability) }

  let(:page) do
    render 'hyrax/devices/attribute_rows', presenter: presenter
    Capybara::Node::Simple.new(rendered)
  end

  it "shows modality info" do
  	expect(page).to have_content("Modality")
  	expect(page).to have_content("MedicalXRayComputedTomography")
  end

  it "shows facility info" do
  	expect(page).to have_content("Facility")
  	expect(page).to have_content("Duke SMIF")
  end
end