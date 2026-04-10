require 'rails_helper'

RSpec.describe CulturalHeritageObjectIndexer do
  context 'AAT API' do
    api_test_url = 'http://vocab.getty.edu/aat/300222484.json'
    skip_message = "Unable to access #{api_test_url}"

    if ApiHelpers.external_api_is_up?(api_test_url)

      context 'is available' do
        subject(:solr_document) { CulturalHeritageObjectIndexer.new(object).generate_solr_document }

        let(:object)            { CulturalHeritageObject.create(title: ['Cultural Heritage Object'], vouchered: ['Yes']) }

        describe 'custom fields' do
          aat_type_ids = ['http://vocab.getty.edu/aat/300222484', # finger puppets
                          'http://vocab.getty.edu/aat/300033340', # Dutch-door bolts
                          'http://vocab.getty.edu/aat/300424453', # dental handles
                          'http://vocab.getty.edu/aat/300420882'] # batter bowls

          aat_material_ids = ['http://vocab.getty.edu/aat/300011666', # Alberene stone
                              'http://vocab.getty.edu/aat/300448599', # cement-stabilized clay
                              'http://vocab.getty.edu/aat/300014346'] # flooring sand

          let(:field_values) { {
            aat_type: aat_type_ids.map { |id| Morphosource::ControlledVocabularies::Getty::Aat.new(::RDF::URI(id)) },
            aat_material: aat_material_ids.map { |id| Morphosource::ControlledVocabularies::Getty::Aat.new(::RDF::URI(id)) },
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
    else
      context 'is unavailable', skip: "#{skip_message}" do
        it {}
      end
    end
  end
end
