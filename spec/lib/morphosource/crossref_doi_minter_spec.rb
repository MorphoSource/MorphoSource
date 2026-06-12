# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::CrossrefDoiMinter do
  before do
    described_class.class_variable_set(:@@xsd_schemas, {})
  end


  describe 'Media configuration methods' do
    it 'returns correct required_params for Media' do
      expect(Morphosource::CrossrefDoiMinter.required_params("Media")).to eq(%w[doi_batch_id title doi url resource_type timestamp publication_year])
    end

    it 'returns correct template_path for Media' do
      expect(Morphosource::CrossrefDoiMinter.template_path("Media")).to eq(Rails.root.join("data", "xmls", "doi.xml.erb"))
    end

    it 'returns correct type_letter for Media' do
      expect(Morphosource::CrossrefDoiMinter.type_letter("Media")).to eq("M")
    end
  end

  describe 'MediaList configuration methods' do
    it 'returns correct required_params for MediaList' do
      expect(Morphosource::CrossrefDoiMinter.required_params("MediaList")).to eq(%w[doi_batch_id title doi url timestamp publication_year])
    end

    it 'returns correct template_path for MediaList' do
      expect(Morphosource::CrossrefDoiMinter.template_path("MediaList")).to eq(Rails.root.join("data", "xmls", "list_doi.xml.erb"))
    end

    it 'returns correct type_letter for MediaList' do
      expect(Morphosource::CrossrefDoiMinter.type_letter("MediaList")).to eq("L")
    end
  end

  describe '.generate_metadata_deposit_xml' do
    around do |example|
      original_shoulder = ENV['CROSSREF_DOI_SHOULDER']
      ENV['CROSSREF_DOI_SHOULDER'] = '10.1234'
      example.run
    ensure
      ENV['CROSSREF_DOI_SHOULDER'] = original_shoulder
    end

    it 'validates Media and MediaList deposits against their own Crossref schema versions' do
      media_xml = described_class.generate_metadata_deposit_xml(
        '000123',
        {
          'title' => 'Example media',
          'url' => 'https://example.test/media/123',
          'resource_type' => 'Dataset',
          'organization' => 'MorphoSource',
          'timestamp' => 1_700_000_000,
          'publication_year' => 2024
        },
        model: "Media"
      )

      media_list_xml = described_class.generate_metadata_deposit_xml(
        '000456',
        {
          'title' => 'Example media list',
          'url' => 'https://example.test/media-lists/456',
          'organization' => 'MorphoSource',
          'child_media' => [{ 'doi' => '10.1234/M123' }],
          'timestamp' => 1_700_000_001,
          'publication_year' => 2024
        },
        model: "MediaList"
      )

      expect(media_xml).to include('xmlns="http://www.crossref.org/schema/4.4.2"')
      expect(media_list_xml).to include('xmlns="http://www.crossref.org/schema/5.4.0"')
    end
  end
end
