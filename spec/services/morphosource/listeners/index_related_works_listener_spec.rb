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
      let(:ie) { FactoryBot.valkyrie_create(:imaging_event_resource, title: ['ie'], with_index: false) }

      it 'skips reindexing and logs' do
        expect(UpdateRelatedWorksIndexJob).not_to receive(:perform_later)
        listener.on_object_metadata_updated(make_event(ie, skip_index_related_works: true))
      end
    end

    context 'when the object is an ImagingEventResource' do
      let(:specimen) { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes']) }
      let(:ie) { FactoryBot.valkyrie_create(:imaging_event_resource, title: ['ie'], physical_object_id: [specimen.id], with_index: false) }

      context 'when there are no media or objects' do
        it 'does not enqueue a reindex job' do
          allow(ie).to receive(:media).and_return([])
          allow(ie).to receive(:objects).and_return([])
          expect(UpdateRelatedWorksIndexJob).not_to receive(:perform_later)
          listener.on_object_metadata_updated(make_event(ie))
        end
      end

      context 'when there are objects but no media' do
        it 'enqueues a reindex job for objects' do
          allow(ie).to receive(:media).and_return([])
          allow(ie).to receive(:objects).and_return([specimen])
          expect(UpdateRelatedWorksIndexJob).to receive(:perform_later).once
          listener.on_object_metadata_updated(make_event(ie))
        end
      end

      context 'when there are media and objects' do
        let(:media_double) { double('media', id: 'media-id-1', collection?: false) }

        before do
          allow(BiologicalSpecimen).to receive(:where).and_return([])
          allow(CulturalHeritageObject).to receive(:where).and_return([])
        end

        it 'enqueues a single combined reindex job' do
          allow(ie).to receive(:media).and_return([media_double])
          allow(ie).to receive(:objects).and_return([specimen])
          expect(UpdateRelatedWorksIndexJob).to receive(:perform_later).once
          listener.on_object_metadata_updated(make_event(ie))
        end
      end

      context 'when media are descendants through ProcessingEvent and Media chains' do
        let(:processing_event) { ProcessingEvent.create(title: ['processing event']) }
        let(:media) { Media.create(title: ['media']) }

        before do
          allow(BiologicalSpecimen).to receive(:where).and_return([])
          allow(CulturalHeritageObject).to receive(:where).and_return([])
          allow(ie).to receive(:child_works_for) do |object|
            case object.id.to_s
            when ie.id.to_s
              [processing_event]
            when processing_event.id.to_s
              [media]
            else
              []
            end
          end
        end

        it 'enqueues descendant media for reindexing' do
          expect(UpdateRelatedWorksIndexJob).to receive(:perform_later)
            .with(array_including(media.id))
          listener.on_object_metadata_updated(make_event(ie))
        end
      end

      context 'when physical_object_id has changed and previously linked objects remain indexed' do
        let(:old_specimen) { BiologicalSpecimen.create(title: ['old specimen'], vouchered: ['Yes']) }
        let(:media_double) { double('media', id: 'media-id-1', collection?: false) }

        before do
          allow(BiologicalSpecimen).to receive(:where).and_return([old_specimen])
          allow(CulturalHeritageObject).to receive(:where).and_return([])
        end

        it 'includes old objects in the reindex job' do
          allow(ie).to receive(:media).and_return([media_double])
          allow(ie).to receive(:objects).and_return([specimen])
          expect(UpdateRelatedWorksIndexJob).to receive(:perform_later)
            .with(array_including('media-id-1', specimen.id, old_specimen.id))
          listener.on_object_metadata_updated(make_event(ie))
        end
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
