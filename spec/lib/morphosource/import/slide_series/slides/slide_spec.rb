# frozen_string_literal: true

require 'rails_helper'
require 'rest-client'

RSpec.describe Morphosource::Import::SlideSeries::Slides::Slide do

  let(:slide_json)  { {} }
  subject           { described_class.new(slide_json) }

  describe 'MEDIA_ARRAY_METHODS' do
    let(:media_array_methods) { %w[description identifier import_url license magnification preview_mode publisher related_url rights_holder short_description slice_thickness unit x_spacing y_spacing z_spacing] }

    it { expect(described_class::MEDIA_ARRAY_METHODS).to match_array(media_array_methods) }

    it 'defines a default method value' do
      media_array_methods.each do |method|
        expect(subject.send(method)).to eq([])
      end
    end
  end

  describe 'MEDIA_STRING_METHODS' do
    let(:media_string_methods) { %w[remote_origin_url visibility] }

    it { expect(described_class::MEDIA_STRING_METHODS).to match_array(media_string_methods) }

    it 'defines a default method value' do
      media_string_methods.each do |method|
        expect(subject.send(method)).to eq('')
      end
    end
  end

  describe 'FILE_ARRAY_METHODS' do
    let(:file_array_methods)  { %w[aperture_value aspect_ratio bit_depth bits_per_sample byte_order capture_device channels color_format color_map color_space compression creator date_created date_modified file_size file_title file_type_extension focal_length format_label height image_type modality orientation original_checksum photometric_interpretation pixel_spacing pixel_representation pixel_spacing_calibration_type profile_name profile_version sample_rate samples_per_pixel scanning_software secondary_capture_device_manufacturer series_date shutter_speed slice_thickness spacing_between_slices well_formed valid width] }

    it { expect(described_class::FILE_ARRAY_METHODS).to match_array(file_array_methods) }

    it 'defines a default method value' do
      file_array_methods.each do |method|
        expect(subject.send(method)).to eq([])
      end
    end
  end

  describe 'FILE_STRING_METHODS' do
    let(:file_string_methods) { %w[file_name original_name] }

    it 'defines a default method value' do
      file_string_methods.each do |method|
        expect(subject.send(method)).to eq('')
      end
    end
  end

  describe 'other slide methods' do
    context 'values are present in slide_json' do
      let(:slide_json)  do
        {
          'http://rs.tdwg.org/dwc/terms/preparations' => "{\"embedding material\":\"paraffin\",\"section stain\":\"Bodian and Cresyl Violet\",\"section thickness\":\"15\"}",
          'http://purl.org/dc/terms/identifier' => 'http://mczbase.mcz.harvard.edu/media/3823260',
          'http://purl.org/dc/terms/description' => 'MCZ_SC-3793_slide-1'
        }
      end

      describe 'description' do
        let(:parsed_preparations) { ['embedding material: paraffin, section stain: Bodian and Cresyl Violet, section thickness: 15'] }
        it { expect(subject.description).to match_array(parsed_preparations) }
      end
      describe 'related_url' do
        let(:related_url) { ['http://mczbase.mcz.harvard.edu/media/3823260'] }
        it { expect(subject.related_url).to match_array(related_url) }
      end
      describe 'short_description' do
        let(:short_description) { ['MCZ_SC-3793_slide-1'] }
        it { expect(subject.short_description).to match_array(short_description) }
      end
      describe 'title' do
        let(:title) { ['MCZ_SC-3793_slide-1 [Image]'] }
        it { expect(subject.title).to match_array(title) }
      end
    end
    context 'values are not present in slide_json' do
      it { expect(subject.description).to match_array([]) }
      it { expect(subject.related_url).to match_array([]) }
      it { expect(subject.short_description).to match_array([]) }
      it { expect(subject.title).to match_array(['[Image]']) }
    end
  end

  describe 'imaging_description' do
    it { expect(subject.imaging_description).to match_array([]) }
  end

  describe 'mime_type' do
    before { allow(subject).to receive(:file_name).and_return(file_name) }
    context 'file_name is present' do
      let(:file_name) { ['filename.tiff'] }
      it { expect(subject.mime_type).to eq('image/tiff') }
    end
    context 'file_name is not present' do
      let(:file_name) { nil }
      it { expect(subject.mime_type).to eq('') }
    end
  end

  describe 'slide_thumbnail_path' do
    it { expect(subject.slide_thumbnail_path).to eq('') }
  end

  describe 'json' do
    let(:key) { 3971235301 }
    let(:uri) { "https://api.gbif.org/v1/occurrence/#{key}" }

    context 'uri is not valid' do
      let(:key)       { 'nonesense' }
      let(:fail_data) do
        { 'message' => '400 Bad Request',
          'request_url' => uri }
      end

      it 'returns an error status' do
        results = subject.json(uri)
        expect(results[:status]).to eq(:fail)
        expect(results[:data]).to eq(fail_data)
      end
    end

    context 'request is successful' do
      it 'returns json result' do
        results = subject.json(uri)
        expect(results[:status]).to eq(:success)
        expect(results[:data]['key']).to eq(key)
      end
    end

    context 'response code is not 200' do
      let(:response)  { instance_double(RestClient::Response, code: 304) }
      before do
        allow(RestClient::Request).to receive(:execute).and_return(response)
      end
      it 'returns a success status with response code' do
        results = subject.json(uri)
        expect(results[:status]).to eq(:fail)
        expect(results[:data]).to eq("Response code: #{response.code}")
      end
    end

    context 'response.body parsing fails' do
      let(:response)  { instance_double(RestClient::Response, code: 200, body: nil) }
      before do
        allow(RestClient::Request).to receive(:execute).and_return(response)
      end
      it 'returns an error status' do
        results = subject.json(uri)
        expect(results[:status]).to eq(:error)
        expect(results[:message]).to eq('Response.body parsing failed.')
      end
    end

    context 'not found error' do
      let(:error) { RestClient::NotFound.new }
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(error)
      end
      it 'returns json search results' do
        expect(Rails.logger).to receive(:error).with("Server returned #{error.message} for #{uri}")
        results = subject.json(uri)
        expect(results[:status]).to eq(:error)
        expect(results[:message]).to eq(error.message)
      end
    end

    context 'timeout error' do
      let(:error) { RestClient::Exceptions::Timeout.new }
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(error)
      end
      it 'returns json search results' do
        expect(Rails.logger).to receive(:error).with("Server returned #{error.message} for #{uri}")
        results = subject.json(uri)
        expect(results[:status]).to eq(:error)
        expect(results[:message]).to eq(error.message)
      end
    end

    context 'some other error' do
      let(:error) { RestClient::Exception.new }
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(error)
      end
      it 'returns json search results' do
        expect(Rails.logger).to receive(:error).with("Server returned #{error.message} for #{uri}")
        results = subject.json(uri)
        expect(results[:status]).to eq(:error)
        expect(results[:message]).to eq(error.message)
      end
    end
  end

  describe 'validate_technical_metadata' do
    let(:short_description) { 'MCZ_SC-3793_slide-1' }
    let(:slide_json)        { { 'http://purl.org/dc/terms/description' => short_description } }
    context 'empty metadata' do
      let(:metadata)  { [{},{}] }
      it 'sets metadata blank' do
        subject.validate_technical_metadata(metadata)
        expect(subject.instance_variable_get(:@metadata_blank)).to be(true)
      end
      it 'returns a blank array' do
        expect(subject.validate_technical_metadata(metadata)).to eq([])
      end
    end
    context 'metadata is present' do
      let(:metadata) { [{ 'metadata' => 'metadata' }, { 'metadata' => 'metadata ' }] }
      it 'does not raise error' do
        expect(subject.validate_technical_metadata(metadata)).to match_array(metadata)
      end
    end
  end
end
