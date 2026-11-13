require 'rails_helper'

RSpec.describe Morphosource::MediaReviewerBatches do
  it 'walks successive cursor pages without loading metadata from Solr' do
    solr = instance_double(Morphosource::SolrService)
    allow(Morphosource::SolrService).to receive(:new).and_return(solr)
    options = { fl: 'id', rows: 500, sort: 'id asc' }
    expect(solr).to receive(:get).with('has_model_ssim:Media', options.merge(cursorMark: '*'))
      .and_return('response' => { 'docs' => [{ 'id' => 'first' }] }, 'nextCursorMark' => 'cursor-1')
    expect(solr).to receive(:get).with('has_model_ssim:Media', options.merge(cursorMark: 'cursor-1'))
      .and_return('response' => { 'docs' => [{ 'id' => 'second' }] }, 'nextCursorMark' => 'cursor-2')
    expect(solr).to receive(:get).with('has_model_ssim:Media', options.merge(cursorMark: 'cursor-2'))
      .and_return('response' => { 'docs' => [] }, 'nextCursorMark' => 'cursor-2')

    ids = []
    described_class.each { |batch| ids.concat(batch) }
    expect(ids).to eq(%w[first second])
  end

  it 'fails instead of silently ending a partial walk when Solr omits the cursor' do
    solr = instance_double(Morphosource::SolrService)
    allow(Morphosource::SolrService).to receive(:new).and_return(solr)
    allow(solr).to receive(:get).and_return('response' => { 'docs' => [] })

    expect { described_class.each { |_ids| } }.to raise_error(KeyError)
  end
end
