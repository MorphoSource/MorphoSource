require 'rails_helper'
require 'rake'

describe 'Media reviewer migration support', type: :task do
  before { Rails.application.load_tasks if Rake::Task.tasks.empty? }

  describe Morphosource::MediaReviewerVerification do
    subject(:verification) { described_class.new }

    let(:owner) { FactoryBot.create(:contributor) }
    let(:reviewer) { FactoryBot.create(:contributor) }
    let!(:media) { FactoryBot.create(:media, owner: owner.ms_id, depositor: owner.ms_id) }

    before { User.batch_user }

    it 'accepts a correctly copied user list with dead ids dropped' do
      media.update!(download_reviewer: [reviewer.ms_id, 'deleted-user'],
                    record_download_reviewer_users: [reviewer.ms_id])

      summary = verification.call

      expect(summary[:total]).to eq(1)
      expect(summary[:backfill_diffs]).to be_empty
      expect(summary[:resolution_diffs]).to be_empty
      expect(verification).to be_verified
    end

    it 'detects a missed copy even when both paths resolve to the owner' do
      media.update!(download_reviewer: [owner.ms_id])

      summary = verification.call

      expect(summary[:backfill_diffs]).to include(id: media.id, expected: [owner.ms_id], actual: [])
      expect(summary[:resolution_diffs]).to be_empty
      expect(verification).not_to be_verified
    end

    it 'detects a reviewer cleared from the old field after backfill' do
      media.update!(download_reviewer: [], record_download_reviewer_users: [reviewer.ms_id])

      summary = verification.call

      expect(summary[:backfill_diffs]).to include(id: media.id, expected: [], actual: [reviewer.ms_id])
      expect(summary[:resolution_diffs].first).to include(expected: [owner.ms_id], actual: [reviewer.ms_id])
      expect(verification).not_to be_verified
    end

    it 'leaves blank source and target fields valid' do
      verification.call

      expect(verification).to be_verified
    end

    context 'with a stored organization id' do
      let(:organization) { FactoryBot.create(:organization_collection, download_reviewer: [reviewer.ms_id]) }

      it 'reports the resolution change when an organization-only value was dropped' do
        media.update!(download_reviewer: [organization.id])

        summary = verification.call

        expect(summary[:backfill_diffs]).to be_empty
        expect(summary[:resolution_diffs].first)
          .to include(reason: :stored_organization, expected: [reviewer.ms_id], actual: [owner.ms_id])
        expect(verification).not_to be_verified
      end

      it 'checks the user half of a mixed value and reports the lost organization reviewers' do
        media.update!(download_reviewer: [organization.id, owner.ms_id],
                      record_download_reviewer_users: [owner.ms_id])

        summary = verification.call

        expect(summary[:backfill_diffs]).to be_empty
        expect(summary[:resolution_diffs].first).to include(reason: :stored_organization, actual: [owner.ms_id])
        expect(summary[:resolution_diffs].first[:expected]).to match_array([owner.ms_id, reviewer.ms_id])
      end

      it 'classifies a stored organization without loading metadata from Fedora' do
        media.update!(download_reviewer: [organization.id, owner.ms_id],
                      record_download_reviewer_users: [owner.ms_id])
        # Legacy resolution needs Fedora; isolate the additional classification lookup.
        allow(media).to receive(:reviewer).and_return([owner.ms_id, reviewer.ms_id])
        allow(Media).to receive(:find).with(media.id).and_return(media)
        allow_any_instance_of(ActiveFedora::Relation).to receive(:load_from_fedora)
          .and_raise('Classification must not load metadata from Fedora')

        summary = verification.call

        expect(summary[:resolution_diffs].first)
          .to include(reason: :stored_organization, actual: [owner.ms_id])
      end
    end

    it 'reports the batch User fallback for an owner organization with no reviewers' do
      organization = FactoryBot.create(:organization_collection)
      media.update!(owner: organization.id)

      summary = verification.call

      expect(summary[:backfill_diffs]).to be_empty
      expect(summary[:resolution_diffs].first)
        .to include(reason: :batch_user_fallback, expected: [], actual: [User.batch_user.ms_id])
      expect(verification).not_to be_verified
    end

    it 'counts stale CartItems across statuses without changing them' do
      approved = CartItem.create!(user_id: owner.ms_id, work_id: media.id,
                                  reviewers: [reviewer.ms_id], date_approved: Time.current)
      current = CartItem.create!(user_id: owner.ms_id, work_id: media.id, reviewers: [owner.ms_id])

      expect(media).not_to receive(:save)
      expect(Hyrax.publisher).not_to receive(:publish)
      summary = verification.call

      expect(summary).to include(cart_items: 2, cart_item_diffs: 1)
      expect(approved.reload.reviewers).to eq([reviewer.ms_id])
      expect(current.reload.reviewers).to eq([owner.ms_id])
      expect(verification).to be_verified
    end

    it 'reports a document whose Fedora record has been deleted' do
      allow(Media).to receive(:find).with(media.id).and_raise(ActiveFedora::ObjectNotFoundError)

      expect(verification.call[:unloadable]).to eq([media.id])
      expect(verification).not_to be_verified
    end

    it 'does not create the batch User when the preflight has not been done' do
      allow(User).to receive(:find_by_user_key).with(User.batch_user_key).and_return(nil)
      expect(User).not_to receive(:batch_user)

      expect { verification.call }.to raise_error(/batch User must exist/)
    end

    it 'returns a failing task status for a backfill difference' do
      media.update!(download_reviewer: [reviewer.ms_id])
      task = Rake::Task['morphosource:download_reviewer:verify_media']
      task.reenable

      expect { task.invoke }.to raise_error(SystemExit) { |error| expect(error.status).to eq(1) }
    end
  end

  describe 'morphosource:download_reviewer:reindex_media' do
    let(:task) { Rake::Task['morphosource:download_reviewer:reindex_media'] }
    let!(:media) { FactoryBot.create(:media) }
    let!(:other_media) { FactoryBot.create(:media) }

    before do
      task.reenable
      # Creating the second work resets the factory's earlier Media.find stub.
      allow(Media).to receive(:find).with(media.id).and_return(media)
      allow(Media).to receive(:find).with(other_media.id).and_return(other_media)
    end

    it 'reindexes every Media synchronously without saving or publishing events' do
      expect(media).to receive(:update_index).once.and_call_original
      expect(other_media).to receive(:update_index).once.and_call_original
      expect(media).not_to receive(:save)
      expect(other_media).not_to receive(:save)
      expect(Hyrax.publisher).not_to receive(:publish)

      task.invoke
    end

    it 'continues after a record failure, fails the task and allows a complete rerun' do
      allow(Morphosource::MediaReviewerBatches).to receive(:each).and_yield([media.id, other_media.id])
      allow(media).to receive(:update_index).and_raise(StandardError, 'Solr unavailable')
      expect(other_media).to receive(:update_index).twice.and_call_original

      expect { task.invoke }.to raise_error(SystemExit)

      allow(media).to receive(:update_index).and_call_original
      task.reenable
      expect { task.invoke }.not_to raise_error
    end
  end
end
