# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Action::UpdateWorkService do
  describe '#call' do
    it 'updates and indexes a device resource' do
      user = FactoryBot.create(:user)
      device = FactoryBot.valkyrie_create(
        :device_resource,
        with_index: false,
        title: ['Old title'],
        modality: ['MicroCT'],
        creator: [user.ms_id],
        depositor: user.ms_id
      )

      params = { device_resource: { title: ['New title'], creator: [user.ms_id] } }

      result = described_class.new(work: device, params: params).call

      expect(result).to be_success

      solr_doc = SolrDocument.find(device.id.to_s)
      expect(solr_doc['has_model_ssim']).to include('DeviceResource')
      expect(solr_doc['title_tesim']).to include('New title')
    end

    it 'replaces a stale Device solr model with DeviceResource' do
      user = FactoryBot.create(:user)
      device = FactoryBot.valkyrie_create(
        :device_resource,
        with_index: false,
        title: ['Old title'],
        modality: ['MicroCT'],
        creator: [user.ms_id],
        depositor: user.ms_id
      )

      ActiveFedora::SolrService.add(
        { 'id' => device.id.to_s, 'has_model_ssim' => 'Device', 'title_tesim' => ['Old title'] },
        commit: true
      )

      params = { device_resource: { title: ['New title'], creator: [user.ms_id] } }

      result = described_class.new(work: device, params: params).call

      expect(result).to be_success

      solr_doc = SolrDocument.find(device.id.to_s)
      expect(solr_doc['has_model_ssim']).to include('DeviceResource')
      expect(solr_doc['title_tesim']).to include('New title')
    end
  end

  describe 'ImagingEventResource' do
    let(:device) do
      FactoryBot.valkyrie_create(:device_resource, with_index: false,
        title: ['device'], modality: ['Photogrammetry'])
    end
    let(:ie) do
      Hyrax.persister.save(resource: ImagingEventResource.new(
        title: ['Test IE'],
        device_id: [device.id.to_s],
        ie_modality: device.modality,
        physical_object_id: ['000']
      ))
    end
    let(:form) { double('form', validate: true, errors: double(messages: {})) }

    before do
      allow(Hyrax::FormFactory).to receive_message_chain(:new, :build).and_return(form)
    end

    subject do
      described_class.new(
        work: ie,
        params: { imaging_event_resource: { title: ['Updated IE'] } }
      )
    end

    describe '#transaction_name' do
      it 'uses change_set.update_work' do
        expect(subject.send(:transaction_name)).to eq('change_set.update_work')
      end
    end

    describe '#step_args' do
      it 'includes save_acl' do
        expect(subject.send(:step_args)).to have_key('work_resource.save_acl')
      end

      it 'does not include set_user_as_depositor' do
        expect(subject.send(:step_args)).not_to have_key('change_set.set_user_as_depositor')
      end
    end

    describe '#call' do
      let(:transaction) { double('transaction') }

      before do
        allow(Hyrax::Transactions::Container).to receive(:[])
          .with('change_set.update_work')
          .and_return(transaction)
        allow(transaction).to receive(:with_step_args).and_return(transaction)
        allow(transaction).to receive(:call).and_return(Dry::Monads::Success(ie))
      end

      it 'dispatches to change_set.update_work' do
        expect(transaction).to receive(:call).with(form)
        subject.call
      end

      context 'when form validation fails' do
        before { allow(form).to receive(:validate).and_return(false) }

        it 'raises an error' do
          expect { subject.call }.to raise_error(/Error updating/)
        end
      end
    end
  end

  describe 'with an unpermitted work type' do
    let(:media) { Media.new }

    subject { described_class.new(work: media, params: {}) }

    it 'raises on transaction_name' do
      expect { subject.send(:transaction_name) }.to raise_error(/Unpermitted work type/)
    end

    it 'raises on step_args' do
      expect { subject.send(:step_args) }.to raise_error(/Unpermitted work type/)
    end
  end
end
