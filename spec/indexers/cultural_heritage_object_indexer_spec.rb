require 'rails_helper'

RSpec.describe CulturalHeritageObjectIndexer do
  subject(:solr_document) { CulturalHeritageObjectIndexer.new(object).generate_solr_document }

  let(:object) { CulturalHeritageObject.create(title: ['Cultural Heritage Object'], vouchered: ['Yes']) }

  describe 'custom fields' do
    aat_type_labels = { '300222484' => 'finger puppets',
                        '300033340' => 'Dutch-door bolts',
                        '300424453' => 'dental handles',
                        '300420882' => 'batter bowls' }

    aat_material_labels = { '300011666' => 'Alberene stone',
                            '300448599' => 'cement-stabilized clay',
                            '300014346' => 'flooring sand' }

    def aat_terms(labels_by_id)
      labels_by_id.map do |id, label|
        term = Morphosource::ControlledVocabularies::Getty::Aat.new(::RDF::URI("http://vocab.getty.edu/aat/#{id}"))
        allow(term).to receive(:rdf_label).and_return([label])
        term
      end
    end

    let(:field_values) { {
      aat_type: aat_terms(aat_type_labels),
      aat_material: aat_terms(aat_material_labels),
      cho_type: ["punch bowl", "dog toy", "airplane"],
      material: ["ceramic", "plastic", "metal"],
      vouchered: ["Yes"]
    } }

    before do
      field_values.each do |k,v|
        allow(object).to receive(k).and_return(v)
      end
    end

    it 'indexes custom fields' do
      expect(subject['material_si']).to eq("alberene stone")
      expect(subject['cho_type_si']).to eq("airplane")
      expect(subject['vouchered_si']).to eq("yes")
    end
  end
end
