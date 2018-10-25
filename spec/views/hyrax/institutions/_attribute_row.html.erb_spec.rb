require 'rails_helper'

RSpec.describe 'hyrax/institutions/_attribute_rows.html.erb', type: :view do
	let(:url) { "http://example.com" }
	let(:ability) { double }
	let(:work) do
		Institution.new({
			title: ['American Museum of Natural History'],
			institution_code: ['AMNH'],
			description: ['A sample description'],
			address: ['Central Park West'],
			city: ['New York City'],
			state_province: ['New York'],
			country: ['United States']
		})
	end
	let(:solr_document) { SolrDocument.new(work.to_solr) }
  let(:presenter) { Hyrax::InstitutionPresenter.new(solr_document, ability) }

  let(:page) do
    render 'hyrax/institutions/attribute_rows', presenter: presenter
    Capybara::Node::Simple.new(rendered)
  end

  it "shows institution_code info" do
  	expect(page).to have_content("Institution code")
  	expect(page).to have_content("AMNH")
  end

  it "shows address info" do
  	expect(page).to have_content("Address")
  	expect(page).to have_content("Central Park West")
  end

  it "shows city info" do
  	expect(page).to have_content("City")
  	expect(page).to have_content("New York City")
  end

  it "shows state/province info" do
  	expect(page).to have_content("State province")
  	expect(page).to have_content("New York")
  end

  it "shows country info" do
  	expect(page).to have_content("Country")
  	expect(page).to have_content("United States")
  end
end