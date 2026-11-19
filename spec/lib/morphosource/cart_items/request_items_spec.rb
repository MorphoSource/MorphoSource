require 'rails_helper'

RSpec.describe Morphosource::CartItems::RequestItems do
  let(:requester) { Object.new.extend(described_class) }
  let(:user) { FactoryBot.create(:user) }
  let(:stale_reviewer) { FactoryBot.create(:contributor) }
  let(:reviewer) { FactoryBot.create(:contributor) }
  let(:other_reviewer) { FactoryBot.create(:contributor) }

  describe '#make_request' do
    it 'replaces reviewers stored at cart-add with the current resolution' do
      media = FactoryBot.create(:media, record_download_reviewer_users: [reviewer.ms_id])
      item = CartItem.create!(user_id: user.ms_id, work_id: media.id, reviewers: [stale_reviewer.ms_id])

      requester.make_request(item)

      expect(item.reviewers).to eq([reviewer.ms_id])
      expect(item.reload.reviewers).to eq([reviewer.ms_id])
      expect(item.date_requested).to be_present
    end

    it 'resolves an organization-owned media with blank record users to the organization' do
      organization = FactoryBot.create(:organization_collection, managers_are_download_reviewers: false,
        custom_download_reviewer_users: [reviewer.ms_id])
      media = FactoryBot.create(:media, owner: organization.id)
      item = CartItem.create!(user_id: user.ms_id, work_id: media.id, reviewers: [stale_reviewer.ms_id])

      requester.make_request([item])

      expect(item.reload.reviewers).to eq([reviewer.ms_id])
    end

    it 'leaves reviewers untouched when the resolution differs only in order' do
      media = FactoryBot.create(:media)
      item = CartItem.create!(user_id: user.ms_id, work_id: media.id, reviewers: [reviewer.ms_id, other_reviewer.ms_id])
      allow_any_instance_of(Morphosource::DownloadReviewerResolver).to receive(:call)
        .and_return([other_reviewer.ms_id, reviewer.ms_id])

      requester.make_request(item)

      expect(item.reload.reviewers).to eq([reviewer.ms_id, other_reviewer.ms_id])
    end

    it 'resolves a batch of media with one resolver' do
      media = Array.new(2) { FactoryBot.create(:media, record_download_reviewer_users: [reviewer.ms_id]) }
      items = media.map { |m| CartItem.create!(user_id: user.ms_id, work_id: m.id, reviewers: [stale_reviewer.ms_id]) }
      expect(Morphosource::DownloadReviewerResolver).to receive(:new).once.and_call_original

      requester.make_request(items)

      expect(items.map { |item| item.reload.reviewers }).to all(eq([reviewer.ms_id]))
    end

    it 'keeps stored reviewers when the media is not in Solr' do
      item = CartItem.create!(user_id: user.ms_id, work_id: 'missing', reviewers: [stale_reviewer.ms_id])

      requester.make_request(item)

      expect(item.reload.reviewers).to eq([stale_reviewer.ms_id])
      expect(item.date_requested).to be_present
    end
  end
end
