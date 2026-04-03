# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Transactions::Steps::DeleteResource do
  subject(:step) { described_class.new(persister: persister, publisher: publisher) }

  let(:persister)  { double('persister', delete: true) }
  let(:publisher)  { double('publisher') }

  describe '#call' do
    context 'when the resource responds to :ark' do
      let(:resource) do
        instance_double('DeviceResource',
                        persisted?: true,
                        collection?: false,
                        id: double(id: 'device-id-1'),
                        ark: ['ark:/99999/fk4/123'])
      end

      before { allow(publisher).to receive(:publish) }

      it 'publishes object.deleted with deleted_ark' do
        step.call(resource, user: nil)

        expect(publisher).to have_received(:publish).with(
          'object.deleted',
          hash_including(
            object: resource,
            deleted_ark: 'ark:/99999/fk4/123'
          )
        )
      end

      it 'returns Success' do
        expect(step.call(resource, user: nil)).to be_success
      end
    end

    context 'when the resource does not respond to :ark' do
      let(:resource) do
        instance_double('TaxonomyResource',
                        persisted?: true,
                        collection?: false,
                        id: double(id: 'taxonomy-id-1'))
      end

      before { allow(publisher).to receive(:publish) }

      it 'publishes object.deleted with deleted_ark: nil' do
        step.call(resource, user: nil)

        expect(publisher).to have_received(:publish).with(
          'object.deleted',
          hash_including(deleted_ark: nil)
        )
      end
    end

    context 'when the resource is a collection' do
      let(:resource) do
        instance_double('Hyrax::PcdmCollection',
                        persisted?: true,
                        collection?: true,
                        id: double(id: 'collection-id-1'))
      end

      before { allow(publisher).to receive(:publish) }

      it 'publishes collection.deleted' do
        step.call(resource, user: nil)

        expect(publisher).to have_received(:publish).with(
          'collection.deleted',
          hash_including(collection: resource)
        )
      end
    end

    context 'when the resource is not persisted' do
      let(:resource) { instance_double('DeviceResource', persisted?: false) }

      it 'returns Failure' do
        expect(step.call(resource)).to be_failure
      end
    end
  end
end
