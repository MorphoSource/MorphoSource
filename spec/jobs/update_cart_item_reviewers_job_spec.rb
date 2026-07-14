# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateCartItemReviewersJob do
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
  end

  it 'sets the resolved reviewers on every cart item for the media' do
    described_class.new.perform(media)

    expect(cart_item.reload.reviewers).to eq([reviewer.ms_id])
    expect(cart_item2.reload.reviewers).to eq([reviewer.ms_id])
  end

  it 'does not touch cart items for other media' do
    expect { described_class.new.perform(media) }
      .not_to change { other_item.reload.reviewers }
  end

  it 'resolves the reviewers once for the media' do
    described_class.new.perform(media)

    expect(Morphosource::DownloadReviewerResolverService)
      .to have_received(:resolve_for_media).once
  end
end
