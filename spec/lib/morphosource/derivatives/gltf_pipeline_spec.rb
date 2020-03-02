require 'rails_helper'

RSpec.describe Morphosource::Derivatives::GltfPipeline do
	let(:source_path) { File.join(fixture_path, 'bunny/bunny.glb') }
	let(:out_path) { Rails.root.join('tmp', 'd45da83d-3a6c-46ac-9888-5b9cefb032b6.glb') }

	let(:gltf_pipeline) { Morphosource::Derivatives::GltfPipeline.new(source_path, out_path) }
	subject { gltf_pipeline }

	context 'call' do
		context 'with missing file' do
			let(:source_path) { '/dev/path/to/bogus/file' }
			it 'should raise GltfPipelineError' do
				expect { subject.call }.to raise_error(Morphosource::Derivatives::GltfPipelineError)
			end
		end

		context 'with valid file' do
			before do
				if File.exist?(out_path)
					File.delete(out_path)
				end
				subject.call
			end

			after do
				if File.exist?(out_path)
					File.delete(out_path)
				end
			end

			it 'should produce derivative glb' do
				expect(File.exist?(out_path)).to be true
			end
		end
	end
end