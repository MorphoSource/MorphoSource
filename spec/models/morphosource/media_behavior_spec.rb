require 'rails_helper'

RSpec.describe Morphosource::MediaBehavior do

  let(:depositor)             { FactoryBot.create(:contributor) }
  let(:user)                  { FactoryBot.create(:registered_user) }
  let(:user2)                 { FactoryBot.create(:registered_user) }
  let(:user3)                 { FactoryBot.create(:registered_user) }

  let(:open_media)            { FactoryBot.create(:public_media, depositor: depositor.ms_id) }
  let(:private_media)         { FactoryBot.create(:private_media, depositor: depositor.ms_id) }
  let(:restricted_media)      { FactoryBot.create(:restricted_media, depositor: depositor.ms_id) }

  let(:open_media_solr)       { SolrDocument.find(open_media.id) }
  let(:private_media_solr)    { SolrDocument.find(private_media.id) }
  let(:restricted_media_solr) { SolrDocument.find(restricted_media.id) }

  describe 'publication_status' do
    it 'is has the correct status' do
      # open
      expect(open_media.publication_status).to eq('open')
      expect(open_media_solr.publication_status).to eq('open')
      # restricted download
      expect(restricted_media.publication_status).to eq('restricted')
      expect(restricted_media_solr.publication_status).to eq('restricted')
      # private
      expect(private_media.publication_status).to eq('private')
      expect(private_media_solr.publication_status).to eq('private')
    end
  end

  describe 'can_add_to_cart?' do
    it 'has the correct value' do
      # open
      expect(open_media.can_add_to_cart?).to be(true)
      expect(open_media_solr.can_add_to_cart?).to be(true)
      # restricted download
      expect(restricted_media.can_add_to_cart?).to be(true)
      expect(restricted_media_solr.can_add_to_cart?).to be(true)
      # private
      expect(private_media.can_add_to_cart?).to be(false)
      expect(private_media_solr.can_add_to_cart?).to be(false)
    end
  end

  describe 'open_download?' do
    it 'has the correct value' do
      # open
      expect(open_media.open_download?).to be(true)
      expect(open_media_solr.open_download?).to be(true)
      # restricted download
      expect(restricted_media.open_download?).to be(false)
      expect(restricted_media_solr.open_download?).to be(false)
      # private
      expect(private_media.open_download?).to be(false)
      expect(private_media_solr.open_download?).to be(false)
    end
  end

  describe 'restricted_download?' do
    it 'has the correct value' do
      # open
      expect(open_media.restricted_download?).to be(false)
      expect(open_media_solr.restricted_download?).to be(false)
      # restricted download
      expect(restricted_media.restricted_download?).to be(true)
      expect(restricted_media_solr.restricted_download?).to be(true)
      # private
      expect(private_media.restricted_download?).to be(false)
      expect(private_media_solr.restricted_download?).to be(false)
    end
  end

  describe 'private?' do
    it 'has the correct value' do
      # open
      expect(open_media.private?).to be(false)
      expect(open_media_solr.private?).to be(false)
      # restricted download
      expect(restricted_media.private?).to be(false)
      expect(restricted_media_solr.private?).to be(false)
      # private
      expect(private_media.private?).to be(true)
      expect(private_media_solr.private?).to be(true)
    end
  end

  describe 'reviewer' do
    context 'media does not have a download reviewer set' do
      context 'media has an owner' do
        before do
          restricted_media.owner = user.ms_id
          restricted_media.save!
        end
        it 'returns the media owner' do
          expect(restricted_media.reviewer).to match_array([user.ms_id])
          expect(restricted_media_solr.reviewer).to match_array([user.ms_id])
        end
      end
      context 'media does not have an owner' do
        it 'returns the media depositor' do
          expect(restricted_media.reviewer).to match_array([depositor.ms_id])
          expect(restricted_media_solr.reviewer).to match_array([depositor.ms_id])
        end
      end
      context 'media is owned by an organization' do
        let(:org) { FactoryBot.create(:organization_collection) }

        before do
          restricted_media.owner = org.id
          restricted_media.save!
        end

        context 'the organization has a download_reviewer set' do
          before do
            org.download_reviewer = [user.ms_id]
            org.save!
          end
          it 'returns the organization download reviewer' do
            expect(restricted_media.reviewer).to match_array([user.ms_id])
            expect(restricted_media_solr.reviewer).to match_array([user.ms_id])
          end
        end

        context 'the organization has no download_reviewer but has managers' do
          before do
            org.managers << user
            org.managers_group.save!
          end
          it 'returns the organization manager ms_ids' do
            expect(restricted_media.reviewer).to match_array([user.ms_id])
            expect(restricted_media_solr.reviewer).to match_array([user.ms_id])
          end
        end
      end
    end
    context 'media does have a download reviewer set' do
      context 'with individual users' do
        before do
          restricted_media.download_reviewer = [user.ms_id, depositor.ms_id]
          restricted_media.save!
        end

        it 'returns the download reviewers' do
          expect(restricted_media.reviewer).to match_array([user.ms_id, depositor.ms_id])
          expect(restricted_media_solr.reviewer).to match_array([user.ms_id, depositor.ms_id])
        end
      end

      context 'with an individual user and multiple organizations' do
        let(:org) { FactoryBot.create(:organization_collection, download_reviewer: [user2.ms_id]) }
        let(:org2) { FactoryBot.create(:organization_collection, download_reviewer: [user3.ms_id]) }

        before do
          restricted_media.download_reviewer = [user.ms_id, org.id, org2.id]
          restricted_media.save!
        end

        it 'returns the individual and every organization reviewer' do
          expected_reviewers = [user.ms_id, user2.ms_id, user3.ms_id]

          expect(restricted_media.reviewer).to match_array(expected_reviewers)
          expect(restricted_media_solr.reviewer).to match_array(expected_reviewers)
        end
      end

      context 'when no configured reviewer exists' do
        before do
          restricted_media.owner = user.ms_id
          restricted_media.download_reviewer = ['missing-reviewer']
          restricted_media.save!
        end

        it 'falls back to the media owner' do
          expect(restricted_media.reviewer).to match_array([user.ms_id])
          expect(restricted_media_solr.reviewer).to match_array([user.ms_id])
        end
      end

      context 'when at least one configured reviewer exists' do
        before do
          restricted_media.owner = depositor.ms_id
          restricted_media.download_reviewer = [user.ms_id, 'missing-reviewer']
          restricted_media.save!
        end

        it 'does not add the media owner' do
          expect(restricted_media.reviewer).to match_array([user.ms_id])
          expect(restricted_media_solr.reviewer).to match_array([user.ms_id])
        end
      end
    end
  end
end
