require 'rails_helper'

RSpec.describe ::SolrDocument, type: :model do
	let(:document) { described_class.new(attributes) }
	let(:attributes) { {} }

	describe "organization metadata field solrizer methods" do
		let(:work) do
			Organization.new({
				title: ['American Museum of Natural History'],
				institution_code: ['AMNH'],
				description: ['A sample description'],
				address: ['Central Park West'],
				city: ['New York City'],
				state_province: ['New York'],
				country: ['United States']
			})
		end

		subject { SolrDocument.new(work.to_solr) }

		it "return institution_code" do
			expect(subject.institution_code.first).to eq('AMNH')
		end

		it "return address" do
			expect(subject.address.first).to eq('Central Park West')
		end

		it "return city" do
			expect(subject.city.first).to eq('New York City')
		end

		it "return state/province" do
			expect(subject.state_province.first).to eq('New York')
		end

		it "return country" do
			expect(subject.country.first).to eq('United States')
		end
  end

  describe '#geographic coordinates' do
    let(:latitude) { '35.994034' }
    let(:longitude) { '-78.898621' }
    before do
      allow(subject).to receive(:latitude) { [ latitude ] }
      allow(subject).to receive(:longitude) { [ longitude ] }
    end
    describe 'latitude and longitude both present' do
      its(:geographic_coordinates) { is_expected.to eq("Latitude: #{latitude}, Longitude: #{longitude}") }
    end
    describe 'longitude missing' do
      before { allow(subject).to receive(:longitude) }
      its(:geographic_coordinates) { is_expected.to eq("Latitude: #{latitude}") }
    end
    describe 'latitude missing' do
      before { allow(subject).to receive(:latitude) }
      its(:geographic_coordinates) { is_expected.to eq("Longitude: #{longitude}") }
    end
  end

  describe "device metadata field solrizer methods" do
		let(:work) do
			Device.new({
				title: ['XTekCT 100'],
				creator: ['Nikon'],
				modality: ['MedicalXRayComputedTomography'],
				description: ['A sample description']
			})
		end

		subject { SolrDocument.new(work.to_solr) }

		it "return modality" do
			expect(subject.modality.first).to eq('MedicalXRayComputedTomography')
		end

  end
end
