# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::CrossrefDoiMinter do

  describe 'Media configuration methods' do
    before do
      subject.instance_variable_set(:@model, "Media")
    end

    it 'returns correct required_params for Media' do
      expect(Morphosource::CrossrefDoiMinter.required_params).to eq(%w[doi_batch_id title doi url resource_type timestamp publication_year])
    end

    it 'returns correct template_path for Media' do
      expect(Morphosource::CrossrefDoiMinter.template_path).to eq(Rails.root.join("data", "xmls", "doi.xml.erb"))
    end

    it 'returns correct type_letter for Media' do
      expect(Morphosource::CrossrefDoiMinter.type_letter).to eq("M")
    end
  end

  describe 'MediaList configuration methods' do
    before do
      subject.instance_variable_set(:@model, "MediaList")
    end

    it 'returns correct required_params for MediaList' do
      expect(Morphosource::CrossrefDoiMinter.required_params).to eq(%w[doi_batch_id title doi url timestamp publication_year])
    end

    it 'returns correct template_path for MediaList' do
      expect(Morphosource::CrossrefDoiMinter.template_path).to eq(Rails.root.join("data", "xmls", "list_doi.xml.erb"))
    end

    it 'returns correct type_letter for MediaList' do
      expect(Morphosource::CrossrefDoiMinter.type_letter).to eq("L")
    end
  end
end