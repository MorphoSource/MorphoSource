require 'rails_helper'

RSpec.describe 'hyrax/devices/_attribute_rows.html.erb', type: :view do
	let(:url) { "http://example.com" }
	let(:ability) { double }
	let(:resource) do
    FactoryBot.build(
      :device_resource,
      title: ['XTekCT 100'],
      creator: ['Nikon'],
      modality: ['MicroNanoXRayComputedTomography'],
      description: ['A sample description']
    )
  end
	let(:solr_document) { SolrDocument.new(DeviceResourceIndexer.new(resource: resource).to_solr) }
  let(:presenter) { Hyrax::DevicePresenter.new(solr_document, ability) }

  let(:page) do
    render 'hyrax/devices/attribute_rows', presenter: presenter
    Capybara::Node::Simple.new(rendered)
  end

  it "shows modality info" do
  	expect(page).to have_content("Modality")
  	expect(page).to have_content("MicroNanoXRayComputedTomography")
  end

end
