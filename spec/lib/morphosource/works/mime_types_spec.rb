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
end