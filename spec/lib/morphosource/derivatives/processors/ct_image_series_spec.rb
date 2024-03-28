require 'rails_helper'

describe Morphosource::Derivatives::Processors::CTImageSeries do
  subject { described_class.new(file_name, directives) }

  let(:file_name) { 'file_name' }
  let(:derivative_path) { '/tmp/test.dcm' }
  let(:directives) { { label: :dcm, format: 'dcm', url: URI("file://#{derivative_path}").to_s } }

  describe "#process" do
    context "when a timeout is set" do
      before do
        subject.timeout = 0.1
        allow(subject).to receive(:create_ct_image_series_derivative) { sleep 0.2 }
      end

      it "raises a TimeoutError" do
        expect { subject.process }.to raise_error Morphosource::Derivatives::Processors::TimeoutError
      end
    end

    context "when a timeout is not set" do
      before { subject.timeout = nil }

      it "processes without a timeout" do
        expect(subject).to receive(:process_with_timeout).never
        expect(subject).to receive(:create_ct_image_series_derivative).once
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

  describe 'correct_spacing_scale' do
    let(:file_name) { File.join(fixture_path, 'dcm_stack.zip') }

    before do
      subject.instance_variable_set(:@x_spacing, 1)
      subject.instance_variable_set(:@y_spacing, 10)
      subject.instance_variable_set(:@z_spacing, 20)
      subject.instance_variable_set(:@slice_thickness, 30)
    end

    context 'unit is micrometers' do
      before do
        subject.instance_variable_set(:@unit, 'Um')
      end
      it 'returns the correct values' do
        subject.send(:correct_spacing_scale)
        expect(subject.x_spacing).to eq(0.001)
        expect(subject.y_spacing).to eq(0.01)
        expect(subject.z_spacing).to eq(0.02)
        expect(subject.slice_thickness).to eq(0.03)
      end
    end
  end
end
