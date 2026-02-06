# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource DeviceResource`
require 'rails_helper'
require 'hyrax/specs/shared_specs/hydra_works'

RSpec.describe DeviceResource do
  subject(:work) { described_class.new }

  it_behaves_like 'a Hyrax::Work'

  context 'includes schema defined metadata' do
    it { is_expected.to respond_to(:modality) }
    it { is_expected.to respond_to(:organization_id) }
    it { is_expected.to respond_to(:ark) }
  end

  describe '#organization' do
    let(:organization) { instance_double('Organization') }

    it 'returns nil when no organization_id is present' do
      expect(work.organization).to be_nil
    end

    it 'finds the organization by id when present' do
      work.organization_id = ['org-123']
      allow(ActiveFedora::Base).to receive(:find).with('org-123').and_return(organization)

      expect(work.organization).to eq(organization)
    end
  end

  describe '#media_docs' do
    it 'queries solr for media docs using the device id' do
      allow(work).to receive(:id).and_return('device-1')
      solr_service = instance_double('Morphosource::SolrService')
      allow(Morphosource::SolrService).to receive(:new).and_return(solr_service)
      expect(solr_service).to receive(:get_docs)
        .with('has_model_ssim:Media AND media_device_id_ssim:device-1')

      work.media_docs
    end
  end

  describe '#media' do
    it 'queries Media by device id' do
      allow(work).to receive(:id).and_return('device-1')
      expect(Media).to receive(:where).with('media_device_id_ssim' => 'device-1')

      work.media
    end
  end
end
