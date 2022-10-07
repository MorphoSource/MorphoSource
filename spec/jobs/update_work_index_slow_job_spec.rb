require 'rails_helper'
RSpec.describe UpdateWorkIndexSlowJob do

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'perform' do
    context 'with one work' do
      let!(:work)  { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes']) }
      let!(:old_solr) { solr(work) }

      it 'serializes and deserializes resource transparently' do
        expect { described_class.perform_later(work.id) }
          .to have_enqueued_job
          .with(work.id)
      end

      it 'reindexes the work' do
        described_class.perform_now(work.id)
        new_solr = solr(work)
        expect(old_solr['_version_']).not_to eq(new_solr['_version_'])
      end
    end

    def solr(work)
      SolrDocument.find(work.id)
    end
  end
end
