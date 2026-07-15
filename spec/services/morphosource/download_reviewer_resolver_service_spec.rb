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

  describe 'resolution' do
    let!(:user)     { FactoryBot.create(:user) }
    let!(:user2)    { FactoryBot.create(:user) }
    let!(:manager)  { FactoryBot.create(:user) }

    describe '.resolve' do
      it 'returns ms_ids of existing users and drops unknown ids' do
        expect(described_class.resolve([user.ms_id, 'missing-id', user2.ms_id]))
          .to match_array([user.ms_id, user2.ms_id])
      end

      context 'with a prefixed org value' do
        let(:org) { FactoryBot.create(:organization_collection, download_reviewer: [user2.ms_id]) }

        it 'expands the org to its reviewers alongside individual users' do
          expect(described_class.resolve([user.ms_id, "org_collection:#{org.id}"]))
            .to match_array([user.ms_id, user2.ms_id])
        end
      end
    end

    describe '.resolve_objects' do
      let(:org) { FactoryBot.create(:organization_collection) }

      it 'returns User and OrganizationCollection records in input order, dropping unknown values' do
        values = ["org_collection:#{org.id}", 'missing-id', user.ms_id]
        resolved = described_class.resolve_objects(values)
        expect(resolved.map(&:id)).to eq([org.id, user.id])
        expect(resolved.first).to be_a(OrganizationCollection)
        expect(resolved.last).to be_a(User)
      end

      it 'returns an empty array for nil' do
        expect(described_class.resolve_objects(nil)).to eq([])
      end
    end

    describe '.resolve_organization' do
      let(:org) { FactoryBot.create(:organization_collection) }

      context 'when the org has a download_reviewer' do
        before do
          org.download_reviewer = [user.ms_id]
          org.save!
        end

        it 'resolves the configured reviewers' do
          expect(described_class.resolve_organization(org)).to eq([user.ms_id])
        end
      end

      context 'when the org has no download_reviewer' do
        before do
          org.managers << manager
          org.managers_group.save!
        end

        it 'falls back to the org managers' do
          expect(described_class.resolve_organization(org)).to eq([manager.ms_id])
        end
      end

      context 'when the org lists itself as download_reviewer (managers checkbox)' do
        before do
          org.managers << manager
          org.managers_group.save!
          org.download_reviewer = ["org_collection:#{org.id}"]
          org.save!
        end

        it 'resolves to the current managers' do
          expect(described_class.resolve_organization(org)).to eq([manager.ms_id])
        end
      end

      context 'when download_reviewer contains an org value other than the org itself' do
        let(:other_org) { FactoryBot.create(:organization_collection, download_reviewer: [user2.ms_id]) }

        # validation prevents orgs from referencing other orgs; if such a
        # value is ever written around validation, it is ignored
        before do
          org.download_reviewer = [user.ms_id, "org_collection:#{other_org.id}"]
          org.save(validate: false)
        end

        it 'ignores the other org' do
          expect(described_class.resolve_organization(org)).to eq([user.ms_id])
        end
      end
    end

    describe '.resolve_for_media' do
      let(:media) { double(download_reviewer: download_reviewer, user_with_ownership: [user.ms_id]) }

      context 'when download_reviewer resolves to users' do
        let(:download_reviewer) { [user2.ms_id] }

        it 'returns the resolved reviewers' do
          expect(described_class.resolve_for_media(media)).to eq([user2.ms_id])
        end
      end

      context 'when download_reviewer is blank' do
        let(:download_reviewer) { [] }

        it 'falls back to the owner' do
          expect(described_class.resolve_for_media(media)).to eq([user.ms_id])
        end
      end

      context 'when download_reviewer resolves to no users' do
        let(:download_reviewer) { ['missing-id'] }

        it 'falls back to the owner' do
          expect(described_class.resolve_for_media(media)).to eq([user.ms_id])
        end
      end

      context 'when the owner is an organization' do
        let(:download_reviewer) { [] }
        let(:org) { FactoryBot.create(:organization_collection, download_reviewer: [user2.ms_id]) }
        let(:media) { double(download_reviewer: download_reviewer, user_with_ownership: [org.id]) }

        it 'resolves the owner org to its reviewers' do
          expect(described_class.resolve_for_media(media)).to eq([user2.ms_id])
        end
      end
    end
  end
end
