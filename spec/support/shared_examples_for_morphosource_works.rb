RSpec.shared_examples 'a Morphosource work' do

  describe 'indexing' do
    it 'indexes a sortable version of the title field' do
      expect(subject.to_solr).to include(Solrizer.solr_name('title', :stored_sortable))
    end
  end

  describe 'whether work type require files' do
    specify {
      expect(described_class.work_requires_files).to be_in([ true, false ])
      expect(described_class.work_requires_files?).to be_in([ true, false ])
    }
  end

end
