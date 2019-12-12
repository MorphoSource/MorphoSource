require 'rails_helper'

RSpec.describe Morphosource::Derivatives::Blender do
	let(:source_path) { File.join(fixture_path, 'bunny/bunny.ply') }
	let(:out_path) { Rails.root.join('tmp', '8aa5d5f5-8cd3-4c3e-9dec-6dbbdff48a2b.glb') }
	let(:units) { nil }
	let(:tool_path) { nil }

	let(:blender) { Morphosource::Derivatives::Blender.new(source_path, out_path, units, tool_path) }
	subject { blender }

	context 'call' do
		context 'with missing file' do
			let(:source_path) { '/dev/path/to/bogus/file' }
			it 'should raise BlenderError' do
				expect { subject.call }.to raise_error(Morphosource::Derivatives::BlenderError)
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