require 'rails_helper'

describe Morphosource::Derivatives::Processors::Mesh do
  subject { described_class.new(file_name, directives) }

  let(:file_name) { 'file_name' }
  let(:derivative_path) { '/tmp/test.glb' }
  let(:directives) { { label: :glb, format: 'glb', unit: 'm', url: URI("file://#{derivative_path}").to_s } }

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
      describe "PLY format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.ply') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exists?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end

      describe "OBJ (single file) format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.obj') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exists?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end

      describe "STL format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.stl') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exists?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end

      describe "WRL format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.wrl') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exists?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end

      describe "X3D format" do
        let(:file_name) { File.join(fixture_path, 'bunny/bunny.x3d') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exists?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end

      describe "OBJ (multi-file ZIP) format" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096-obj.zip') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exists?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end

      describe "OBJ (multi-file TAR) format" do
        let(:file_name) { File.join(fixture_path, 'whale/whale-mpc-677-150k-4096-obj.tar') }

        it "produces the derivative mesh with a non-zero filesize" do
          subject.process
          expect(File.exists?(derivative_path)).to be true
          expect(File.size(derivative_path)).to be > 0
        end
      end
    end
  end
end