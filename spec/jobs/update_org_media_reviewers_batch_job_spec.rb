require 'rails_helper'

RSpec.describe UpdateOrgMediaReviewersBatchJob do
  let(:owner)    { FactoryBot.create(:contributor) }
  let(:reviewer) { FactoryBot.create(:contributor) }

  it 'runs on the update_slow queue' do
    expect(described_class.new.queue_name).to eq(Hyrax.config.update_slow_queue_name.to_s)
  end

  it 'shares one resolver across the batch' do
    media = Array.new(2) { FactoryBot.create(:media, owner: owner.ms_id, record_download_reviewer_users: [reviewer.ms_id]) }

    expect(Morphosource::DownloadReviewerResolver).to receive(:new).once.and_call_original

    described_class.perform_now(media.map(&:id))
  end

  it 'skips Media no longer in Solr' do
    item = CartItem.create!(user_id: owner.ms_id, work_id: 'deleted-media', reviewers: [owner.ms_id])

    described_class.perform_now(['deleted-media'])

    expect(item.reload.reviewers).to eq([owner.ms_id])
  end

  it "resolves each Media's current identity" do
    media = FactoryBot.create(:media, owner: owner.ms_id, record_download_reviewer_users: [reviewer.ms_id])
    item = CartItem.create!(user_id: owner.ms_id, work_id: media.id, reviewers: [owner.ms_id])

    described_class.perform_now([media.id])

    expect(item.reload.reviewers).to eq([reviewer.ms_id])
  end
end
