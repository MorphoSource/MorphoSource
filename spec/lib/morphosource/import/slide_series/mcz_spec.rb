# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MCZ Metadata' do

  describe 'GBIF occurrence metadata' do
    it 'is formatted as expected' do
      recent = recent_gbif_upload
      expect(recent['key'].present?).to be(true)
      expect(recent['occurrenceID'].present?).to be(true)
      expect(recent['publishingOrgKey']).to eq('b4640710-8e03-11d8-b956-b8a03c50a862')
      # slides
      slides = slides(recent)
      expect(slides.present?).to be(true)
      # individual slide
      slide = slides.first
      expect(slide['http://purl.org/dc/terms/identifier'].present?).to be(true)
      expect(slide['http://rs.tdwg.org/ac/terms/associatedSpecimenReference'].present?).to be(true)
      expect(slide['http://purl.org/dc/terms/description'].present?).to be(true)
      expect(slide['http://rs.tdwg.org/ac/terms/resourceCreationTechnique']).to eq('Sequential Section Scan')
      expect(slide['http://rs.tdwg.org/ac/terms/variant']).to eq('ac:BestQuality')
      expect(slide['http://rs.tdwg.org/ac/terms/accessURI']).to include('default.png')
      expect(slide['http://purl.org/dc/terms/title'].present?).to be(true)
      expect(slide['http://rs.tdwg.org/dwc/terms/scientificName'].present?).to be(true)
      # MCZ iiif json
      iiif_json, iiif_exif = mcz_iiif(slide)
      expect(iiif_json['originalFilename'].present?).to be(true)
      expect(iiif_json['fileSize'].present?).to be(true)
      # MCZ iiif_exif
      expect(iiif_exif['ImageWidth'].present?).to be(true)
      expect(iiif_exif['ImageLength'].present?).to be(true)
      expect(iiif_exif['BitsPerSample'].present?).to be(true)
      expect(iiif_exif['Compression'].present?).to be(true)
      expect(iiif_exif['PhotometricInterpretation'].present?).to be(true)
      expect(iiif_exif['ImageDescription'].present?).to be(true)
      expect(iiif_exif['Make'].present?).to be(true)
      # checks that device is included in mcz devices on prod.
      # device names should match prod Organization.find('000357979').devices.map { |d| d.title.first }
      expect(['IQ222', 'TissueScope LE 120']).to include(iiif_exif['Model'])
      expect(iiif_exif['SamplesPerPixel'].present?).to be(true)
      expect(iiif_exif['XResolution'].present?).to be(true)
      expect(iiif_exif['YResolution'].present?).to be(true)
      expect(iiif_exif['ResolutionUnit'].present?).to be(true)
      expect(iiif_exif['Software'].present?).to be(true)
      expect(iiif_exif['DateTime'].present?).to be(true)
    end
  end

  def recent_gbif_upload
    Morphosource::Import::Slides::GetNewSlidesService.new.gbif_search_results.max_by { |k| k['modified'] }
  rescue StandardError
    'GBIF API error'
  end

  def mcz_iiif(slide)
    mcz_slide = Morphosource::Import::SlideSeries::Slides::MczSlide.new(slide)
    [mcz_slide.instance_variable_get(:@iiif_json), mcz_slide.instance_variable_get(:@iiif_exif)['fields']]
  rescue StandardError
    'MCZ IIIF API error'
  end

  def slides(recent)
    media = recent['extensions']['http://rs.tdwg.org/ac/terms/Multimedia']
    media.select { |s| (s['http://rs.tdwg.org/ac/terms/variant'] == 'ac:BestQuality') && (s['http://rs.tdwg.org/ac/terms/accessURI'].include? '/full/') }
  end
end
