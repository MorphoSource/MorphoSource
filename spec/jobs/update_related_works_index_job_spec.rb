require 'rails_helper'
RSpec.describe UpdateRelatedWorksIndexJob do

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'perform' do
    context 'with one work' do
      let!(:work)  { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes']) }
      let!(:old_solr) { solr(work) }

      it 'serializes and deserializes resource transparently' do
        expect { described_class.perform_later([work.id]) }
          .to have_enqueued_job
          .with([work.id])
      end

      it 'enqueues a further UpdateWorkIndexJob for the work' do
        described_class.perform_now([work.id])
        
        expect(UpdateWorkIndexJob)
          .to have_been_enqueued
          .with(work.id)
      end
    end

    context 'with multiple works' do
      let!(:media1) { Media.create(title: ['media1']) }
      let!(:media2) { Media.create(title: ['media2']) }
      let!(:media3) { Media.create(title: ['media3']) }
      let!(:media1_old_solr)  { solr(media1) }
      let!(:media2_old_solr)  { solr(media2) }
      let!(:media3_old_solr)  { solr(media3) }

      it 'reindexes all the works' do
        described_class.perform_now([media1.id, media2.id, media3.id])

        expect(UpdateWorkIndexJob)
          .to have_been_enqueued
          .with(media1.id)

        expect(UpdateWorkIndexJob)
          .to have_been_enqueued
          .with(media2.id)

        expect(UpdateWorkIndexJob)
          .to have_been_enqueued
          .with(media3.id)

        # media1_new_solr = solr(media1)
        # media2_new_solr = solr(media2)
        # media3_new_solr = solr(media3)

        # expect(media1_old_solr['_version_']).not_to eq(media1_new_solr['_version_'])
        # expect(media2_old_solr['_version_']).not_to eq(media2_new_solr['_version_'])
        # expect(media3_old_solr['_version_']).not_to eq(media3_new_solr['_version_'])
      end
    end

    describe 'reindex_collections' do
      let(:collection_type) { Hyrax::CollectionType.create(title: 'collection_type') }
      let!(:collection)     { Collection.create(title: ['collection'], collection_type_gid: collection_type.to_global_id) }
      let!(:old_solr)       { solr(collection) }

      it 'reindexes the collection' do
        described_class.new.reindex_collections([collection.id])
        new_solr = solr(collection)
        expect(old_solr['_version_']).not_to eq(new_solr['_version_'])
      end
    end

    def solr(work)
      SolrDocument.find(work.id)
    end
  end
end
