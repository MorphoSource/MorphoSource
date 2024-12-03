require 'rails_helper'

# require GltfTransform to ensure GltfTransformError gets autoloaded
require 'morphosource/derivatives/gltf_transform'

describe Morphosource::Derivatives::Processors::MeshGltf do
  subject { described_class.new(file_name, directives) }

  let(:file_name) { 'file_name' }
  let(:derivative_path) { '/tmp/test.glb' }
  let(:directives) { { label: :glb, format: 'glb', unit: 'mm', url: URI("file://#{derivative_path}").to_s } }

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

    context "with an input file" do
      describe "where file does not exist " do
        let(:file_name) { File.join(fixture_path, 'fake.glb') }

        it "raises Morphosource::Derivatives::GltfTransformError" do
          expect { subject.process }.to raise_error(an_instance_of(Morphosource::Derivatives::GltfTransformError))
        end
      end

      describe "simple mesh GLB format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.glb') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end

      describe "simple mesh GLTF (single file) format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.gltf') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end

      describe "complex mesh GLB format" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096.glb') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end

      describe "complex mesh GLTF (multi-file ZIP) format" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096-gltf.zip') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end

      describe "complex mesh GLTF (multi-file ZIP) format in meter scale" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096-gltf.zip') }
        let(:directives) { { label: :glb, format: 'glb', unit: 'm', url: URI("file://#{derivative_path}").to_s } }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end

      describe "complex mesh GLTF (multi-file ZIP) format with no scale" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096-gltf.zip') }
        let(:directives) { { label: :glb, format: 'glb', unit: nil, url: URI("file://#{derivative_path}").to_s } }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end

      describe "complex mesh GLTF (multi-file TAR) format" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096-gltf.tar') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end
    end
  end
end