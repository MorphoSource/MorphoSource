require 'rails_helper'

RSpec.describe UpdateOrgMediaReviewersJob do
  let(:owner)               { FactoryBot.create(:contributor) }
  let(:manager)             { FactoryBot.create(:contributor) }
  let(:other_manager)       { FactoryBot.create(:contributor) }
  let(:organization)        { FactoryBot.create(:organization_collection, title: ['Org A']) }
  let(:other_organization)  { FactoryBot.create(:organization_collection, title: ['Org B']) }
  let(:batch_user_ms_id)    { User.batch_user.ms_id }

  # Changes membership without reindexing, as CollectionRolesController does.
  def add_manager(organization, new_manager)
    organization.managers << new_manager
    organization.managers_group.save!
  end

  def token_for(organization)
    "org_collection:#{organization.id}"
  end

  # Stubs the identity before saving so the indexer writes the tokens without building an
  # Object Organization graph.
  def media_identified_by(*identities)
    media = FactoryBot.build(:media, owner: owner.ms_id)
    allow(media).to receive(:download_reviewers).and_return(identities)
    media.save!
    media
  end

  def cart_item_for(work_id, status = {})
    CartItem.create!({ user_id: owner.ms_id, work_id: work_id, reviewers: [owner.ms_id] }.merge(status))
  end

  describe 'the parent job' do
    before { ActiveJob::Base.queue_adapter = :test }

    it 'runs on the update_fast queue' do
      expect(described_class.new.queue_name).to eq(Hyrax.config.update_fast_queue_name.to_s)
    end

    it 'reindexes the organization before querying for its Media' do
      allow(OrganizationCollection).to receive(:find).with(organization.id).and_return(organization)
      expect(organization).to receive(:update_index).ordered
      expect(ActiveFedora::SolrService).to receive(:query).ordered.and_return([])

      described_class.perform_now(organization.id)
    end

    it 'escapes the token and puts the OR set in fq' do
      expect(ActiveFedora::SolrService).to receive(:query) do |query, args|
        expect(query).to eq('has_model_ssim:Media')
        expect(args[:fq].first).to start_with("download_reviewers_ssim:org_collection\\:#{organization.id} OR ")
        expect(args[:fl]).to eq('id')
        []
      end

      described_class.perform_now(organization.id)
    end

    it 'enqueues one batch per 500 Media' do
      hits = Array.new(501) { |i| { 'id' => "media-#{i}" } }
      allow(ActiveFedora::SolrService).to receive(:query).and_return(hits)

      expect { described_class.perform_now(organization.id) }
        .to have_enqueued_job(UpdateOrgMediaReviewersBatchJob).exactly(2).times
      batches = ActiveJob::Base.queue_adapter.enqueued_jobs.map { |job| job[:args].first.size }
      expect(batches).to eq([500, 1])
    end

    it 'still refreshes Media when the organization has been deleted' do
      allow(OrganizationCollection).to receive(:find).and_raise(ActiveFedora::ObjectNotFoundError)
      allow(ActiveFedora::SolrService).to receive(:query).and_return([{ 'id' => 'media-1' }])

      expect { described_class.perform_now('deleted-organization') }
        .to have_enqueued_job(UpdateOrgMediaReviewersBatchJob).with(['media-1'])
    end
  end

  describe 'refreshing cart items' do
    before do
      add_manager(organization, manager)
      add_manager(other_organization, other_manager)
      organization.update_index
      other_organization.update_index
    end

    it "keeps every organization's reviewers on a Media shared between two when one changes" do
      media = media_identified_by(token_for(organization), token_for(other_organization))
      item = cart_item_for(media.id)
      new_manager = FactoryBot.create(:contributor)
      add_manager(organization, new_manager)

      described_class.perform_now(organization.id)

      expect(item.reload.reviewers).to match_array([manager.ms_id, new_manager.ms_id, other_manager.ms_id])
    end

    it 'refreshes cart items of every status' do
      media = media_identified_by(token_for(organization))
      statuses = [{}, { date_requested: Time.current }, { date_approved: Time.current },
                  { date_approved: 2.days.ago, date_expired: 1.day.ago },
                  { date_denied: Time.current }, { date_canceled: Time.current },
                  { date_downloaded: Time.current }]
      items = statuses.map { |status| cart_item_for(media.id, status) }

      described_class.perform_now(organization.id)

      expect(items.map { |item| item.reload.reviewers }).to all(eq([manager.ms_id]))
    end

    it 'leaves Media naming only other organizations untouched' do
      media = media_identified_by(token_for(other_organization))
      item = cart_item_for(media.id)

      described_class.perform_now(organization.id)

      expect(item.reload.reviewers).to eq([owner.ms_id])
    end

    it 'writes nothing on a re-run' do
      media = media_identified_by(token_for(organization))
      item = cart_item_for(media.id)
      described_class.perform_now(organization.id)
      updated_at = item.reload.updated_at

      described_class.perform_now(organization.id)

      expect(item.reload.updated_at).to eq(updated_at)
    end

    it 'does not fail the batch on a token naming a deleted organization' do
      media = media_identified_by(token_for(organization), 'org_collection:deleted-organization')
      item = cart_item_for(media.id)

      expect { described_class.perform_now(organization.id) }.not_to raise_error
      expect(item.reload.reviewers).to eq([manager.ms_id])
    end

    it "falls back to the batch User once the organization's last reviewer is deleted" do
      media = media_identified_by(token_for(organization))
      item = cart_item_for(media.id)
      manager.delete

      described_class.perform_now(organization.id)

      expect(item.reload.reviewers).to eq([batch_user_ms_id])
    end

    describe 'documents indexed before download_reviewer_mode_ssi' do
      def index_legacy_document(id, model)
        ActiveFedora::SolrService.add({ id: id, has_model_ssim: [model], user_with_ownership_ssi: organization.id },
                                      softCommit: true)
      end

      it 'refreshes Media the organization owns' do
        index_legacy_document('legacy-media', 'Media')
        item = cart_item_for('legacy-media')

        described_class.perform_now(organization.id)

        expect(item.reload.reviewers).to eq([manager.ms_id])
      end

      it 'ignores other records the organization owns' do
        index_legacy_document('legacy-specimen', 'BiologicalSpecimen')
        item = cart_item_for('legacy-specimen')

        described_class.perform_now(organization.id)

        expect(item.reload.reviewers).to eq([owner.ms_id])
      end
    end
  end
end
