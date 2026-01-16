require 'rails_helper'

describe Morphosource::Derivatives::Processors::MeshThumbnail do
  subject { described_class.new(file_name, directives) }

  let(:file_name) { 'file_name' }
  let(:file_set)  { FactoryBot.create(:file_set) }
  let(:derivative_path) { Morphosource::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail') }
  let(:derivative_url) { URI("file://#{Morphosource::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail')}").to_s }
  let(:directives) { { label: :thumbnail, url: derivative_url } }

  describe "#process" do
    context "when a timeout is set" do
      before do
        subject.timeout = 0.1
        allow(subject).to receive(:create_thumbnail_derivative) { sleep 0.2 }
      end

      it "raises a TimeoutError" do
        expect { subject.process }.to raise_error Morphosource::Derivatives::Processors::TimeoutError
      end
    end

    context "when a timeout is not set" do
      before { subject.timeout = nil }

      it "processes without a timeout" do
        expect(subject).to receive(:process_with_timeout).never
        expect(subject).to receive(:create_thumbnail_derivative).once
        subject.process
      end
    end

    context "with an input file" do
      before do
        response = instance_double(
          RestClient::Response,
          code: 200,
          body: File.open(File.join(fixture_path, 'images/duke.png')).read
        )

        allow(RestClient::Request).to receive(:execute).and_return(response)
      end

      describe "simple model GLB format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.ply') }

        it "produces the derivative 2D image thumbnail with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end

      describe "complex textured model GLB format" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096.glb') }

        it "produces the derivative 2D image thumbnail with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end
    end
  end
end