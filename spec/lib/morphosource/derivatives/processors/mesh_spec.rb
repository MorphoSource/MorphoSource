require 'rails_helper'

describe Morphosource::Derivatives::Processors::Mesh do
	subject { described_class.new(file_name, directives) }

	# let(:file_name) { File.join(fixture_path, 'bunny/bunny.ply') }
	let(:file_name) { 'file_name' }
	# let(:source_path) { File.join(fixture_path, 'bunny/bunny.ply') }
	let(:directives) { { label: :glb, format: 'glb', unit: 'm' } }

	describe "#process" do
		context "when a timeout is set" do
			before do
				subject.timeout = 0.1
				allow(subject).to receive(:create_mesh_derivative) { sleep 0.2 }
			end

			it "raises a TimeoutError" do
				expect { subject.process }.to raise_error Morphosource::Derivatives::Processors::TimeoutError
			end
		end

		context "when a timeout is not set" do
			before { subject.timeout = nil }

			it "processes without a timeout" do
				expect(subject).to receive(:process_with_timeout).never
				expect(subject).to receive(:create_mesh_derivative).once
				subject.process
			end
		end

		context "when running the complete commmand" do
			let(:file_name) { File.join(fixture_path, 'bunny/bunny.ply') }

			it "produces the derivative mesh" do
				expect(Hyrax::PersistDerivatives).to receive(:call).with(kind_of(String), directives)
				subject.process
			end
		end
	end
end