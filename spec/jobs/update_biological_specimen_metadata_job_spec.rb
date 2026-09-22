# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateBiologicalSpecimenMetadataJob do
  let(:specimen) { create(:biological_specimen, catalog_number: ['orig-cat-num']) }

  describe '#perform' do
    it 'updates attributes present on the record, accepting a bare id' do
      described_class.perform_now({ id: specimen.id, catalog_number: ['new-cat-num'] })

      expect(specimen.reload.catalog_number).to eq(['new-cat-num'])
    end

    it 'updates attributes present on the record, accepting an id wrapped in an array' do
      described_class.perform_now({ id: [specimen.id], catalog_number: ['new-cat-num'] })

      expect(specimen.reload.catalog_number).to eq(['new-cat-num'])
    end

    it 'ignores keys that are not attributes on the record' do
      expect do
        described_class.perform_now({ id: specimen.id, not_a_real_attribute: ['x'] })
      end.not_to raise_error
    end

    it 'ignores blank values by default' do
      described_class.perform_now({ id: specimen.id, catalog_number: [] })

      expect(specimen.reload.catalog_number).to eq(['orig-cat-num'])
    end

    it 'assigns blank values when allow_blank_values is true' do
      described_class.perform_now({ id: specimen.id, catalog_number: [] }, allow_blank_values: true)

      expect(specimen.reload.catalog_number).to eq([])
    end

    it 'sets skip_index_related_works on the record when true' do
      allow(ActiveFedora::Base).to receive(:exists?).with(specimen.id).and_return(true)
      allow(ActiveFedora::Base).to receive(:find).with(specimen.id).and_return(specimen)
      allow(specimen).to receive(:save!)

      described_class.perform_now({ id: specimen.id }, skip_index_related_works: true)

      expect(specimen.skip_index_related_works).to eq(true)
    end

    it 'allows visibility, depositor, on_behalf_of, and owner to be assigned' do
      described_class.perform_now(
        {
          id: specimen.id,
          visibility: 'restricted',
          depositor: 'someone-else',
          on_behalf_of: 'proxy-user',
          owner: 'org-123'
        }
      )

      specimen.reload
      expect(specimen.visibility).to eq('restricted')
      expect(specimen.depositor).to eq('someone-else')
      expect(specimen.on_behalf_of).to eq('proxy-user')
      expect(specimen.owner).to eq('org-123')
    end

    it 'treats representative_id and thumbnail_id as assignable (not protected)' do
      properties = described_class.new.send(:assignable_properties, specimen)

      expect(properties).to include(:representative_id, :thumbnail_id)
    end

    it 'does not mass-assign protected/system attributes' do
      described_class.perform_now({ id: specimen.id, state: 'deleted', admin_set_id: 'other-admin-set' })

      specimen.reload
      expect(specimen.state).not_to eq('deleted')
      expect(specimen.admin_set_id).not_to eq('other-admin-set')
    end

    it 'does nothing when no record exists for the given id' do
      expect do
        described_class.perform_now({ id: 'nonexistent-id', catalog_number: ['new-cat-num'] })
      end.not_to raise_error
    end
  end
end
