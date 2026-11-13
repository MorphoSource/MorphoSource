require 'rails_helper'

RSpec.describe Morphosource::IDigBioUpdateService do
  describe 'idigbio_link_origin' do
    let(:specimen) do
      BiologicalSpecimen.create(title: ['title'], vouchered: ['Yes'], institution_code: ['MVZ'], idigbio_uuid: ['uuid1'], idigbio_link_origin: link_origin)
    end
    let(:params_for_update) do
      { canonical_taxonomy_id: nil, taxonomy_id_array: [], taxonomy_params_array: [],
        biospec_model_params: { 'gbif_occurrence_key' => '123', 'remote_source' => 'gbif' } }
    end

    def updated_origin(system_update:)
      service = described_class.new(specimen.id, false, system_update, params_for_update)
      service.call
      service.specimen.idigbio_link_origin.to_a
    end

    context 'when a user made the existing link' do
      let(:link_origin) { ['user'] }

      it 'stays "user" when the sync adds a GBIF key' do
        expect(updated_origin(system_update: true)).to eq(['user'])
      end
    end

    context 'when there is no origin yet' do
      # created without an iDigBio UUID, since before_create sets "user" for specimens created with one
      let(:specimen) { BiologicalSpecimen.create(title: ['title'], vouchered: ['Yes'], institution_code: ['MVZ']) }

      it 'is "system_generated" when the sync adds the link' do
        expect(updated_origin(system_update: true)).to eq(['system_generated'])
      end

      it 'is "user" when a user adds the link' do
        expect(updated_origin(system_update: false)).to eq(['user'])
      end
    end

    context 'when the sync made the existing link' do
      let(:link_origin) { ['system_generated'] }

      it 'becomes "user" when a user changes it' do
        expect(updated_origin(system_update: false)).to eq(['user'])
      end
    end
  end
end
