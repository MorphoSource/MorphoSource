# spec/services/morphosource/countries_service_spec.rb
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::CountriesService do

  let(:authority) { described_class.new }

  describe '#continent' do
    context 'for item with a "term" propery' do
      context 'for a country with a single continent' do
        subject { authority.continent('United States') }

        it { is_expected.to eq('North America') }
      end
      context 'for a country with multiple continents' do
        subject { authority.continent('Armenia') }

        it { is_expected.to match_array(['Asia', 'Europe']) }
      end
    end

    context 'for item without a "term" property' do
      it 'will raise KeyError' do
        expect { authority.continent('active-no-term-id') }
          .to raise_error(KeyError)
      end

      it 'accepts a block for a backup value' do
        expect(authority.continent('active-no-term-id') { :backup } )
          .to eq :backup
      end
    end
  end

  describe 'config/authorities/countries.yml' do
    let(:countries)         { YAML.load_file('config/authorities/countries.yml')['terms'] }
    let(:continents)        { countries.map{|c| c['continent']}.flatten.uniq }
    let(:valid_continents)  { ['Africa', 'Asia', 'Europe', 'North America', 'Oceania', 'South America'] }

    it 'should contain expected continent values' do
      expect(continents).to match_array(valid_continents) # check that all continent names are valid
      expect(countries.select { |c| c['continent'].blank? } ).to be_empty # check that all countries have a continent
    end
  end
end