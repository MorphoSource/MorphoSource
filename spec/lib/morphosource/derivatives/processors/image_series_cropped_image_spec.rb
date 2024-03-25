require 'rails_helper'

describe Morphosource::Derivatives::Processors::ImageSeriesCroppedImage do
  subject { described_class.new(file_name, directives) }

  let(:file_name) { 'file_name' }
  let(:derivative_path) { '/tmp/test.jpg' }
  let(:directives) { { label: :dcm, format: 'dcm', url: URI("file://#{derivative_path}").to_s } }

  describe "#process" do
    context "when a timeout is set" do
      before do
        subject.timeout = 0.1
        allow(subject).to receive(:create_image_series_cropped_image_derivative) { sleep 0.2 }
      end

      it "raises a TimeoutError" do
        expect { subject.process }.to raise_error Morphosource::Derivatives::Processors::TimeoutError
      end
    end

    context "when a timeout is not set" do
      before { subject.timeout = nil }

      it "processes without a timeout" do
        expect(subject).to receive(:process_with_timeout).never
        expect(subject).to receive(:create_image_series_cropped_image_derivative).once
        subject.process
      end
    end

    context "with an input file" do
      context "where input zip file does not exist" do
        let(:file_name) { File.join(fixture_path, 'fake.zip') }
  
        it "raises Zip::Error" do
          expect { subject.process }.to raise_error Zip::Error
        end
      end

      context "where input tar file does not exist" do
        let(:file_name) { File.join(fixture_path, 'fake.tar') }
  
        it "raises Errno::ENOENT" do
          expect { subject.process }.to raise_error Errno::ENOENT
        end
      end

      context "ZIP archive format" do
        let(:file_name) { File.join(fixture_path, 'dcm_stack/dcm_stack.zip') }
  
        it "produces the derivative dcm" do
          subject.process
					expect(File.exists?(derivative_path)).to be true
					expect(File.size(derivative_path)).to be > 0
        end
      end

      context "TAR archive format" do
        let(:file_name) { File.join(fixture_path, 'dcm_stack/dcm_stack.tar') }
  
        it "produces the derivative dcm" do
          subject.process
					expect(File.exists?(derivative_path)).to be true
					expect(File.size(derivative_path)).to be > 0
        end
      end
    end
  end
end
