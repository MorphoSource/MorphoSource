# frozen_string_literal: true

require 'rails_helper'
require 'rest-client'

RSpec.describe Morphosource::Import::SlideSeries::Slides::MczSlide do

  let(:slide_json)  { {} }
  subject           { described_class.new(slide_json) }
  let(:identifier)  { '3823260' }
  let(:base_uri)    { "https://iiif.mcz.harvard.edu/iiif/3/#{identifier}" }

  before do
    allow_any_instance_of(described_class).to receive(:validate_technical_metadata).and_return(true)
  end

  describe 'initialize' do
    it 'calls gather_technical_metadata' do
      expect_any_instance_of(described_class).to receive(:gather_technical_metadata)
      subject
    end
  end

  describe 'gather_technical_metadata' do
    it 'gathers and validates technical metadata' do
      expect_any_instance_of(described_class).to receive(:iiif_json)
      expect_any_instance_of(described_class).to receive(:iiif_exif)
      expect_any_instance_of(described_class).to receive(:validate_technical_metadata)
      subject
    end
  end

  describe 'iiif_base_uri_methods' do
    context 'value is present' do
      let(:slide_json)  { { 'http://rs.tdwg.org/ac/terms/accessURI' => "#{base_uri}/full/max/0/default.png" } }

      describe 'iiif_base_uri' do
        it { expect(subject.iiif_base_uri).to eq(base_uri) }
      end
      describe 'identifier' do
        it { expect(subject.identifier).to match_array([identifier]) }
      end
      describe 'remote_origin_url' do
        before do
          allow(subject).to receive(:file_name).and_return(['default.tif'])
        end
        it { expect(subject.remote_origin_url).to eq("#{base_uri}/full/max/0/default.tif") }
      end
      describe 'remote_manifest_url' do
        it { expect(subject.remote_manifest_url).to eq("#{base_uri}/info.json") }
      end
      describe 'slide_thumbnail_path' do
        it { expect(subject.slide_thumbnail_path).to eq("#{base_uri}/full/400,/0/default.jpg") }
      end
    end

    context 'value is empty' do
      describe 'iiif_base_uri' do
        it { expect(subject.iiif_base_uri).to eq(nil) }
      end
      describe 'get_iiif_json' do
        it { expect(subject.get_iiif_json).to eq({}) }
      end
      describe 'identifier' do
        it { expect(subject.identifier).to match_array([]) }
      end
      describe 'remote_origin_url' do
        it { expect(subject.remote_origin_url).to eq('') }
      end
      describe 'remote_manifest_url' do
        it { expect(subject.remote_manifest_url).to eq(nil) }
      end
      describe 'slide_thumbnail_path' do
        it { expect(subject.slide_thumbnail_path).to eq(nil) }
      end
    end
  end

  describe '@iiif_json methods' do
    context 'values are present in @iiif_json' do
      let(:iiif_json) do
        { 'id' => 'http://iiif.mcz.harvard.edu/iiif/3/3823260',
          'width' => 154431,
          'height' => 223142,
          'exif' => {
            'tagSet' => 'Baseline TIFF',
            'fields' => {}
          },
          'originalFilename' => 'MCZ_SC-3793_slide-1.tif',
          'fileSize' => 3325675996 }
      end
      before do
        allow_any_instance_of(described_class).to receive(:iiif_json).and_return(iiif_json)
        subject.instance_variable_set(:@iiif_json, iiif_json)
      end
      describe 'iiif_exif' do
        it { expect(subject.iiif_exif).to eq(iiif_json['exif']) }
      end
      describe 'file_name' do
        it { expect(subject.file_name).to eq([iiif_json['originalFilename']]) }
      end
      describe 'file_size' do
        it { expect(subject.file_size).to eq([iiif_json['fileSize']]) }
      end
      describe 'height' do
        it { expect(subject.height).to eq([iiif_json['height'].to_s]) }
      end
      describe 'width' do
        it { expect(subject.width).to eq([iiif_json['width'].to_s]) }
      end
    end
    context 'values are empty' do
      describe 'iiif_exif' do
        it { expect(subject.iiif_exif).to eq({}) }
      end
      describe 'file_name' do
        it { expect(subject.file_name).to eq([]) }
      end
      describe 'file_size' do
        it { expect(subject.file_size).to eq([]) }
      end
      describe 'height' do
        it { expect(subject.height).to eq([]) }
      end
      describe 'width' do
        it { expect(subject.width).to eq([]) }
      end
    end
  end

  describe '@iiif_exif methods' do
    before do
      subject.instance_variable_set(:@iiif_exif, iiif_exif)
    end

    context 'values are present in @iiif_exif' do
      let(:iiif_exif) do
        { 'fields' => {
            'ImageWidth' => 154431,
            'ImageLength' => 223142,
            'BitsPerSample' => 8,
            'Compression' => 7,
            'PhotometricInterpretation' => 6,
            'ImageDescription' => 'Scan Size = 38.61x55.79 mm\nImage Dimensions = 154431x223142 Pixels\nResolution = 0.25 um\nSource = Bright Field\nScan Started = 2023:03:20 13:04:34\nScan Duration = 00:32:19\nCompress Option = JPEG\nCompress Method = Lossy\nImage Quality = 0.900000\n',
            'Make' => 'Huron Digital Pathology',
            'Model' => 'TissueScope LE 120',
            'XResolution' => {
              'numerator' => 40000,
              'denominator' => 1 },
            'YResolution' => {
              'numerator' => 40000,
              'denominator' => 1 },
            'ResolutionUnit' => 3,
            'Software' => 'MACROscan 1.32',
            'DateTime' => '2023:03:20 13:04:34' }
        }
      end
      let(:fields)  { iiif_exif['fields'] }
      describe 'device' do
        it { expect(subject.device).to eq(fields['Model']) }
      end
      describe 'bits_per_sample' do
        it { expect(subject.bits_per_sample).to eq([fields['BitsPerSample']]) }
      end
      describe 'color_space' do
        it { expect(subject.color_space).to eq(['YCbCr']) }
      end
      describe 'compression' do
        it { expect(subject.compression).to eq(['JPEG']) }
      end
      describe 'date_created' do
        it { expect(subject.date_created).to eq(['2023-03-20']) }
      end
      describe 'imaging_description' do
        it { expect(subject.imaging_description).to eq([fields['ImageDescription']]) }
      end
      describe 'pixel_spacing' do
        it { expect(subject.pixel_spacing).to eq(['0.000025 \\ 0.000025']) }
      end
      describe 'scanning_software' do
        it { expect(subject.scanning_software).to eq([fields['Software']]) }
      end
      describe 'unit' do
        it { expect(subject.unit).to eq(['Cm']) }
      end
      describe 'x_spacing' do
        it { expect(subject.x_spacing).to eq(['0.000025']) }
      end
      describe 'y_spacing' do
        it { expect(subject.y_spacing).to eq(['0.000025']) }
      end
    end
    context 'values are empty' do
      let(:iiif_exif) { {} }
      describe 'device' do
        it { expect(subject.device).to eq(nil) }
      end
      describe 'bits_per_sample' do
        it { expect(subject.bits_per_sample).to eq([]) }
      end
      describe 'color_space' do
        it { expect(subject.color_space).to eq([]) }
      end
      describe 'compression' do
        it { expect(subject.compression).to eq([]) }
      end
      describe 'date_created' do
        it { expect(subject.date_created).to eq([]) }
      end
      describe 'imaging_description' do
        it { expect(subject.imaging_description).to eq([]) }
      end
      describe 'pixel_spacing' do
        it { expect(subject.pixel_spacing).to eq([]) }
      end
      describe 'scanning_software' do
        it { expect(subject.scanning_software).to eq([]) }
      end
      describe 'unit' do
        it { expect(subject.unit).to eq([]) }
      end
      describe 'x_spacing' do
        it { expect(subject.x_spacing).to eq([]) }
      end
      describe 'y_spacing' do
        it { expect(subject.y_spacing).to eq([]) }
      end
    end
  end
end
