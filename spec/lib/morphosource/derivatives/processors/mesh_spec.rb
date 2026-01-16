require 'rails_helper'

# require GltfTransform to ensure GltfTransformError gets autoloaded
require 'morphosource/derivatives/gltf_transform'

describe Morphosource::Derivatives::Processors::Mesh do
  subject { described_class.new(file_name, directives) }

  let(:file_set)  { FactoryBot.create(:file_set) }
  let(:derivative_path) { Morphosource::DerivativePath.derivative_path_for_reference(file_set, 'glb') }
  let(:derivative_url) { URI("file://#{Morphosource::DerivativePath.derivative_path_for_reference(file_set, 'glb')}").to_s }
  let(:file_name) { 'file_name' }
  let(:directives) {{
    label: :glb,
    format: 'glb',
    unit: 'm',
    url: derivative_url
  }}

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

        it "raises Morphosource::Derivatives::MeshError" do
          expect { subject.process }.to raise_error(an_instance_of(Morphosource::Derivatives::GltfTransformError))
        end
      end

      describe "simple mesh GLB format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.glb') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "simple mesh GLTF (single file) format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.gltf') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "complex mesh GLB format" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096.glb') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "PLY format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.ply') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "OBJ (single file) format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.obj') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "STL format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.stl') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "WRL format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.wrl') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "X3D format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.x3d') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "OBJ (multi-file ZIP) format" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096-obj.zip') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "OBJ (multi-file TAR) format" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096-obj.tar') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "complex mesh GLTF (multi-file ZIP) format" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096-gltf.zip') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "complex mesh GLTF (multi-file ZIP) format in meter scale" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096-gltf.zip') }
        let(:directives) { { label: :glb, format: 'glb', unit: 'm', url: URI("file://#{derivative_path}").to_s } }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "complex mesh GLTF (multi-file ZIP) format with no scale" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096-gltf.zip') }
        let(:directives) { { label: :glb, format: 'glb', unit: nil, url: URI("file://#{derivative_path}").to_s } }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "complex mesh GLTF (multi-file TAR) format" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096-gltf.tar') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end

      describe "ZIP (DEFLATE64 ZIP) format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny_deflate64.zip') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exist?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 10000
        end
      end
    end
  end
end