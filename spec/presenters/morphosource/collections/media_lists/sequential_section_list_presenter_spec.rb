require 'rails_helper'

RSpec.describe Morphosource::Collections::MediaLists::SequentialSectionListPresenter do

  let(:main_app)  { Rails.application.routes.url_helpers }

  let(:id)        { '123' }
  let(:list)      { double('list', id: id) }
  let(:solr_doc)  { double('solr doc', id: id) }

  subject { described_class.new(solr_doc, double)}

  before do
    allow(Collection).to receive(:find).with(id).and_return(list)
    allow(list).to receive(:managers).and_return([])
  end

  describe 'edit_path' do
    it { expect(subject.edit_path).to eq(main_app.sequential_section_list_edit_path( { :id => id, :locale => 'en' } )) }
  end

  describe 'collection_type_title' do
    it { expect(subject.collection_type_title).to eq("Sequential Section List") }
  end
end