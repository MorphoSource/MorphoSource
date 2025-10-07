require 'rails_helper'

RSpec.describe Morphosource::Collections::MediaListPresenter do

  let(:main_app)    { Rails.application.routes.url_helpers }

  let(:id)          { '123' }
  let(:media_list)  { double('media list', id: id) }
  let(:solr_doc)    { double('solr doc', id: id) }

  subject { described_class.new(solr_doc, double)}

  before do
    allow(Collection).to receive(:find).with(id).and_return(media_list)
    allow(media_list).to receive(:managers).and_return([])
  end

  describe 'edit_path' do
    it { expect(subject.edit_path).to eq(main_app.media_list_edit_path( { :id => id, :locale => 'en' } )) }
  end

  describe 'collection_type_title' do
    it { expect(subject.collection_type_title).to eq("Media List") }
  end

  describe '#doi_badge' do
    context 'when doi is present' do
      before do
        allow(subject).to receive(:doi).and_return(['10.1111/media.12345'])
      end

      it 'returns a span with the DOI and badge classes' do
        expect(subject.doi_badge).to include('DOI: 10.1111/media.12345')
        expect(subject.doi_badge).to include('badge')
        expect(subject.doi_badge).to include('badge-info')
      end
    end

    context 'when doi is empty' do
      before do
        allow(subject).to receive(:doi).and_return([])
      end

      it 'returns an empty string' do
        expect(subject.doi_badge).to eq('')
      end
    end

    context 'when doi is nil' do
      before do
        allow(subject).to receive(:doi).and_return(nil)
      end

      it 'returns an empty string' do
        expect(subject.doi_badge).to eq('')
      end
    end
  end
end