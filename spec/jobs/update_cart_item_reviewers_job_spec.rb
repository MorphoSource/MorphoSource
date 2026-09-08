require 'rails_helper'

RSpec.describe UpdateCartItemReviewersJob do
  let(:owner) { FactoryBot.create(:contributor) }
  let(:reviewer) { FactoryBot.create(:contributor) }
  let(:other_reviewer) { FactoryBot.create(:contributor) }
  let(:media) { FactoryBot.create(:media, owner: owner.ms_id, record_download_reviewer_users: [reviewer.ms_id]) }

  before { ActiveJob::Base.queue_adapter = :test }

  it 'resolves current metadata and refreshes cart items of every status' do
    statuses = [{}, { date_requested: Time.current }, { date_approved: Time.current },
                { date_approved: 2.days.ago, date_expired: 1.day.ago },
                { date_denied: Time.current }, { date_canceled: Time.current },
                { date_downloaded: Time.current }]
    items = statuses.map do |status|
      CartItem.create!({ user_id: owner.ms_id, work_id: media.id, reviewers: [owner.ms_id] }.merge(status))
    end
    media.update!(record_download_reviewer_users: [other_reviewer.ms_id])

    described_class.perform_now(media.id)

    expect(items.map { |item| item.reload.reviewers }).to all(eq([other_reviewer.ms_id]))
  end

  it 'skips writes when the reviewer set is unchanged, including a retry' do
    media.update!(record_download_reviewer_users: [reviewer.ms_id, other_reviewer.ms_id])
    CartItem.create!(user_id: owner.ms_id, work_id: media.id, reviewers: [other_reviewer.ms_id, reviewer.ms_id])
    expect_any_instance_of(CartItem).not_to receive(:update!)

    2.times { described_class.perform_now(media.id) }
  end

  it 'resolves an object organization through the resolver' do
    organization = FactoryBot.create(:organization_collection, reviews_object_media_downloads: true,
                                      managers_are_download_reviewers: false,
                                      custom_download_reviewer_users: [reviewer.ms_id])
    allow(media).to receive(:organizations).and_return([organization])
    media.update!(download_reviewer_mode: 'object_organization')
    allow(Media).to receive(:find).with(media.id).and_return(media)
    item = CartItem.create!(user_id: owner.ms_id, work_id: media.id, reviewers: [owner.ms_id])

    described_class.perform_now(media.id)

    expect(item.reload.reviewers).to eq([reviewer.ms_id])
  end
end
