RSpec.shared_examples 'a Morphosource work' do

  describe 'whether work type require files' do
    specify {
      expect(described_class.work_requires_files).to be_in([ true, false ])
      expect(described_class.work_requires_files?).to be_in([ true, false ])
    }
  end

end
