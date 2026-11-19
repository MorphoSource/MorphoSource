require 'rails_helper'

RSpec.describe Morphosource::Works::MimeTypes do
	subject { FileSet.new }

	describe '#mesh?' do
		before do
			allow(subject).to receive(:mime_type).and_return('model/gltf+json')
		end

		it 'is true' do
			expect(subject.mesh?).to be true
		end
	end

	describe '.normalize_mime_type' do
		it 'maps GNU tar to application/x-tar' do
			expect(described_class.normalize_mime_type('application/x-gtar')).to eq('application/x-tar')
		end

		it 'leaves other mime types unchanged' do
			expect(described_class.normalize_mime_type('application/zip')).to eq('application/zip')
			expect(described_class.normalize_mime_type(nil)).to be_nil
		end
	end

	describe 'GNU tar mime type' do
		before do
			allow(subject).to receive(:mime_type).and_return('application/x-gtar')
		end

		it 'is an archive and a volume' do
			expect(subject.archive?).to be true
			expect(subject.volume?).to be true
		end
	end
end
