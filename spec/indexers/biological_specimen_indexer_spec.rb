require 'rails_helper'

RSpec.describe BiologicalSpecimenIndexer do
  subject(:solr_document)    { BiologicalSpecimenIndexer.new(specimen).generate_solr_document }
  let(:specimen)             { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes']) }

  describe 'custom fields' do
    let(:field_values) { {
      taxonomies_titles: ['Genus > Species'],
      record_source: 'iDigBio Aggregator'
    } }

    before do
      field_values.each do |k,v|
        allow(specimen).to receive(k).and_return(v)
      end
    end

    it 'indexes taxonomies' do
      expect(subject['taxonomy_ssim']).to match_array field_values[:taxonomies_titles]
      expect(subject['taxonomy_ssim']).to match_array field_values[:taxonomies_titles]
    end

    it 'indexes record source' do
      expect(subject['record_source_ssim']).to eq field_values[:record_source]
    end
  end
end
