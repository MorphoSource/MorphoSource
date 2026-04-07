# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Listeners::IndexRelatedWorksListener do
  subject(:listener) { described_class.new }

  def make_event(object, extra = {})
    event = double('event')
    payload = { object: object }.merge(extra)
    allow(event).to receive(:payload).and_return(payload)
    event
  end

  describe '#on_object_metadata_updated' do
    context 'when the object is not a Valkyrie::Resource' do
      let(:media) { FactoryBot.create(:media) }

      it 'skips reindexing and logs' do
        expect(UpdateRelatedWorksIndexJob).not_to receive(:perform_later)
        listener.on_object_metadata_updated(make_event(media))
      end
    end

    context 'when skip_index_related_works flag is set' do
      let(:ie) { Hyrax.persister.save(resource: ImagingEventResource.new(title: ['ie'])) }

      it 'skips reindexing and logs' do
        expect(UpdateRelatedWorksIndexJob).not_to receive(:perform_later)
        listener.on_object_metadata_updated(make_event(ie, skip_index_related_works: true))
      end
    end

    context 'when the object is an ImagingEventResource' do
      let(:specimen) { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes']) }
      let(:ie) do
        ie = ImagingEventResource.new(title: ['ie'], physical_object_id: [specimen.id])
        Hyrax.persister.save(resource: ie)
      end

      it 'enqueues reindex jobs for related media and objects' do
        allow(ie).to receive(:media).and_return([])
        allow(ie).to receive(:objects).and_return([specimen])
        expect(UpdateRelatedWorksIndexJob).to receive(:perform_later).once
        listener.on_object_metadata_updated(make_event(ie))
      end
    end

    context 'when the object is a TaxonomyResource' do
      let(:taxonomy) { Hyrax.persister.save(resource: TaxonomyResource.new(title: ['taxon'])) }

      it 'enqueues reindex jobs for related objects and media' do
        allow(taxonomy).to receive(:objects).and_return([])
        allow(taxonomy).to receive(:media).and_return([])
        expect(UpdateRelatedWorksIndexJob).not_to receive(:perform_later)
        listener.on_object_metadata_updated(make_event(taxonomy))
      end
    end

  end
end
