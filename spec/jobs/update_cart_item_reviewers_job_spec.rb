# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateCartItemReviewersJob do
  subject(:job) { described_class.new }

  let!(:requester) { FactoryBot.create(:user) }
  let!(:reviewer)  { FactoryBot.create(:user) }
  let(:media_id)   { 'media-1' }
  let(:media)      { double(id: media_id) }

  let!(:cart_item)  { CartItem.create!(user: requester, work_id: media_id, date_requested: Date.current) }
  let!(:cart_item2) { CartItem.create!(user: requester, work_id: media_id) }
  let!(:other_item) { CartItem.create!(user: requester, work_id: 'other-media') }

  before do
    allow(Morphosource::DownloadReviewerResolverService)
      .to receive(:resolve_for_media).with(media).and_return([reviewer.ms_id])
    allow(job).to receive(:cart_item_message_content).and_return('media details')
    allow(job).to receive(:user_email_link).and_return('requestor link')
    allow(job).to receive(:email_sender).and_return(instance_double(User))
    allow(job).to receive(:deliver_message)
  end

  it 'sets the resolved reviewers on every cart item for the media' do
    job.perform(media)

    expect(cart_item.reload.reviewers).to eq([reviewer.ms_id])
    expect(cart_item2.reload.reviewers).to eq([reviewer.ms_id])
  end

  it 'does not touch cart items for other media' do
    expect { job.perform(media) }
      .not_to change { other_item.reload.reviewers }
  end

  context 'when a cart item has a nil reviewers column' do
    before { cart_item.update_column(:reviewers, nil) }

    it 'still sets the resolved reviewers and treats them all as new' do
      job.perform(media)

      expect(cart_item.reload.reviewers).to eq([reviewer.ms_id])
      expect(job).to have_received(:deliver_message).once
    end
  end

  it 'resolves the reviewers once for the media' do
    job.perform(media)

    expect(Morphosource::DownloadReviewerResolverService)
      .to have_received(:resolve_for_media).once
  end

  context 'when given a media id string' do
    let(:media_doc) { double(id: media_id) }

    before do
      allow(SolrDocument).to receive(:find).with(media_id).and_return(media_doc)
      allow(Morphosource::DownloadReviewerResolverService)
        .to receive(:resolve_for_media).with(media_doc).and_return([reviewer.ms_id])
    end

    it 'resolves the media solr document and updates its cart items' do
      job.perform(media_id)

      expect(cart_item.reload.reviewers).to eq([reviewer.ms_id])
    end

    context 'when the media has been deleted' do
      before do
        allow(SolrDocument).to receive(:find).with(media_id)
          .and_raise(Blacklight::Exceptions::RecordNotFound)
      end

      it 'leaves the cart items alone without raising' do
        expect { job.perform(media_id) }
          .not_to change { cart_item.reload.reviewers }
      end
    end
  end

  describe 'reviewer messaging' do
    it 'messages reviewers newly added to an outstanding request only' do
      job.perform(media)

      # cart_item2 also gains the reviewer but has no outstanding request
      expect(job).to have_received(:deliver_message)
        .with(anything, reviewer, anything, 'You have a download request to review').once
    end

    it 'does not message reviewers already on the request' do
      cart_item.update!(reviewers: [reviewer.ms_id])

      job.perform(media)

      expect(job).not_to have_received(:deliver_message)
    end

    it 'does not message when reviewers are only removed' do
      cart_item.update!(reviewers: [reviewer.ms_id, 'departing-reviewer'])

      job.perform(media)

      expect(job).not_to have_received(:deliver_message)
    end

    it 'does not message reviewers added to a cleared request' do
      cart_item.update!(date_cleared: Date.current)

      job.perform(media)

      expect(job).not_to have_received(:deliver_message)
    end

    it 'does not message reviewers added to an expired request' do
      cart_item.update!(date_expired: Date.current - 1)

      job.perform(media)

      expect(job).not_to have_received(:deliver_message)
    end
  end
end
