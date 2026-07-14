# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::DownloadReviewerResolverService do
  describe '.org_value?' do
    it 'is true for prefixed org values' do
      expect(described_class.org_value?('org_collection:abc123')).to be true
    end

    it 'is false for bare user ms_ids' do
      expect(described_class.org_value?('000123456')).to be false
    end

    it 'is false for nil' do
      expect(described_class.org_value?(nil)).to be false
    end
  end

  describe '.org_value' do
    it 'prefixes an organization collection id' do
      expect(described_class.org_value('abc123')).to eq('org_collection:abc123')
    end
  end

  describe '.org_id' do
    it 'strips the prefix from an org value' do
      expect(described_class.org_id('org_collection:abc123')).to eq('abc123')
    end

    it 'returns a bare value unchanged' do
      expect(described_class.org_id('abc123')).to eq('abc123')
    end
  end

  describe '.partition_values' do
    it 'splits values into user ms_ids and unprefixed org ids' do
      values = ['000123456', 'org_collection:abc123', '000654321', 'org_collection:def456']

      expect(described_class.partition_values(values))
        .to eq([['000123456', '000654321'], ['abc123', 'def456']])
    end

    it 'wraps a single value' do
      expect(described_class.partition_values('000123456')).to eq([['000123456'], []])
    end

    it 'returns empty arrays for nil' do
      expect(described_class.partition_values(nil)).to eq([[], []])
    end
  end
end
