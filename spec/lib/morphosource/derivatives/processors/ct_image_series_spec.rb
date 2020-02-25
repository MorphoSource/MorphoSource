require 'rails_helper'

describe Morphosource::Derivatives::Processors::CTImageSeries, :skiptravis => true do
	subject { described_class.new(file_name, directives) }

	# let(:file_name) { File.join(fixture_path, 'bunny/bunny.ply') }
	let(:file_name) { 'file_name' }
	# let(:source_path) { File.join(fixture_path, 'bunny/bunny.ply') }
	let(:directives) { { label: :dcm, format: 'dcm' } }

	describe "#process" do
		context "when a timeout is set" do
			before do
				subject.timeout = 0.1
				allow(subject).to receive(:create_ct_image_series_derivative) { sleep 0.2 }
			end

			xit "raises a TimeoutError" do
				expect { subject.process }.to raise_error Morphosource::Derivatives::Processors::TimeoutError
			end
		end

		context "when a timeout is not set" do
			before { subject.timeout = nil }

			xit "processes without a timeout" do
				expect(subject).to receive(:process_with_timeout).never
				expect(subject).to receive(:create_ct_image_series_derivative).once
				subject.process
			end
		end

		context "when running the complete commmand" do
			let(:file_name) { File.join(fixture_path, 'dcm_stack.zip') }

			xit "produces the derivative dcm" do
				expect(Hyrax::PersistDerivatives).to receive(:call).with(kind_of(String), directives)
				subject.process
			end
		end
	end
end