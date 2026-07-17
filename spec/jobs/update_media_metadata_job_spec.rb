# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateMediaMetadataJob do
  let(:media) { create(:media, short_description: ['orig description']) }

  describe '#perform' do
    it 'updates attributes present on the record, accepting a bare id' do
      described_class.perform_now({ id: media.id, short_description: ['new description'] })

      expect(media.reload.short_description).to eq(['new description'])
    end

    it 'updates attributes present on the record, accepting an id wrapped in an array' do
      described_class.perform_now({ id: [media.id], short_description: ['new description'] })

      expect(media.reload.short_description).to eq(['new description'])
    end

    it 'ignores blank values by default' do
      described_class.perform_now({ id: media.id, short_description: [] })

      expect(media.reload.short_description).to eq(['orig description'])
    end

    it 'assigns blank values when allow_blank_values is true' do
      described_class.perform_now({ id: media.id, short_description: [] }, allow_blank_values: true)

      expect(media.reload.short_description).to eq([])
    end

    it 'sets skip_index_related_works on the record when true' do
      allow(ActiveFedora::Base).to receive(:exists?).with(media.id).and_return(true)
      allow(ActiveFedora::Base).to receive(:find).with(media.id).and_return(media)
      allow(media).to receive(:save!)

      described_class.perform_now({ id: media.id }, skip_index_related_works: true)

      expect(media.skip_index_related_works).to eq(true)
    end

    it 'allows organization_transfer_on_publish and pending_org_transfer to be assigned' do
      described_class.perform_now(
        { id: media.id, organization_transfer_on_publish: true, pending_org_transfer: true }
      )

      media.reload
      expect(media.organization_transfer_on_publish).to eq(true)
      expect(media.pending_org_transfer).to eq(true)
    end

    it 'allows flipping a boolean attribute to false without allow_blank_values' do
      media.update!(organization_transfer_on_publish: true)

      described_class.perform_now({ id: media.id, organization_transfer_on_publish: false })

      expect(media.reload.organization_transfer_on_publish).to eq(false)
    end

    it 'allows visibility, depositor, on_behalf_of, and owner to be assigned' do
      described_class.perform_now(
        {
          id: media.id,
          visibility: 'open',
          depositor: 'someone-else',
          on_behalf_of: 'proxy-user',
          owner: 'org-123'
        }
      )

      media.reload
      expect(media.visibility).to eq('open')
      expect(media.depositor).to eq('someone-else')
      expect(media.on_behalf_of).to eq('proxy-user')
      expect(media.owner).to eq('org-123')
    end

    it 'treats representative_id and thumbnail_id as assignable (not protected)' do
      properties = described_class.new.send(:assignable_properties, media)

      expect(properties).to include(:representative_id, :thumbnail_id)
    end

    it 'does not mass-assign protected/system attributes' do
      described_class.perform_now({ id: media.id, state: 'deleted', admin_set_id: 'other-admin-set' })

      media.reload
      expect(media.state).not_to eq('deleted')
      expect(media.admin_set_id).not_to eq('other-admin-set')
    end

    it 'does nothing when no record exists for the given id' do
      expect do
        described_class.perform_now({ id: 'nonexistent-id', short_description: ['new description'] })
      end.not_to raise_error
    end
  end
end
