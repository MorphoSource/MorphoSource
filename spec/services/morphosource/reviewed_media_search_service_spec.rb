require 'rails_helper'

RSpec.describe Morphosource::ReviewedMediaSearchService do
  let(:reviewer) { FactoryBot.create(:contributor) }
  let(:owner) { FactoryBot.create(:contributor) }

  it 'finds direct duties and organization duties without including unrelated media or collections' do
    organization = FactoryBot.create(:organization_collection)
    organization.managers << reviewer
    organization.managers_group.save!
    organization.update_index
    direct = FactoryBot.create(:media, owner: owner.ms_id, record_download_reviewer_users: [reviewer.ms_id])
    owned = FactoryBot.create(:media, owner: organization.id)
    unrelated = FactoryBot.create(:media, owner: owner.ms_id)

    expect(described_class.call(ms_id: reviewer.ms_id).map { |doc| doc['id'] })
      .to match_array([direct.id, owned.id])
  end

  it 'follows custom organization reviewers without requiring eligibility or manager membership' do
    organization = FactoryBot.create(:organization_collection, reviews_object_media_downloads: false,
                                      managers_are_download_reviewers: false,
                                      custom_download_reviewer_users: [reviewer.ms_id])
    media = FactoryBot.create(:media, owner: organization.id)

    expect(described_class.call(ms_id: reviewer.ms_id).map { |doc| doc['id'] }).to eq([media.id])
  end

  it 'does not assign a custom-mode organization to its other managers' do
    organization = FactoryBot.create(:organization_collection, managers_are_download_reviewers: false,
                                      custom_download_reviewer_users: [owner.ms_id])
    organization.managers << reviewer
    organization.managers_group.save!
    organization.update_index
    FactoryBot.create(:media, owner: organization.id)

    expect(described_class.call(ms_id: reviewer.ms_id)).to be_empty
  end

  context 'with Media indexed before ticket 3' do
    def index_without_reviewer_identities(media)
      ActiveFedora::SolrService.add(media.to_solr.except('download_reviewers_ssim', 'download_reviewer_mode_ssi'),
                                    softCommit: true)
    end

    it 'matches a user-owned document by owner' do
      media = FactoryBot.create(:media, owner: reviewer.ms_id)
      index_without_reviewer_identities(media)

      expect(described_class.call(ms_id: reviewer.ms_id).map { |doc| doc['id'] }).to eq([media.id])
    end

    it 'matches an organization-owned document through the organization' do
      organization = FactoryBot.create(:organization_collection, managers_are_download_reviewers: false,
                                        custom_download_reviewer_users: [reviewer.ms_id])
      media = FactoryBot.create(:media, owner: organization.id)
      index_without_reviewer_identities(media)

      expect(described_class.call(ms_id: reviewer.ms_id).map { |doc| doc['id'] }).to eq([media.id])
    end

    it 'does not match by owner when a current document indexed an empty list' do
      FactoryBot.create(:media, owner: reviewer.ms_id, download_reviewer_mode: 'object_organization')

      expect(described_class.call(ms_id: reviewer.ms_id)).to be_empty
    end

    it 'does not match by owner once the document carries reviewer identities' do
      other = FactoryBot.create(:contributor)
      FactoryBot.create(:media, owner: reviewer.ms_id, record_download_reviewer_users: [other.ms_id])

      expect(described_class.call(ms_id: reviewer.ms_id)).to be_empty
    end
  end
end
