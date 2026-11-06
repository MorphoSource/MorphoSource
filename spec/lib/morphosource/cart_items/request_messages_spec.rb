require 'rails_helper'

RSpec.describe Morphosource::CartItems::RequestMessages do
  let(:sender) { Object.new.extend(described_class) }
  let(:reviewer) { FactoryBot.create(:contributor) }
  let(:other_reviewer) { FactoryBot.create(:contributor) }

  it 'names resolved organization reviewers in request messages' do
    organization = FactoryBot.create(:organization_collection, managers_are_download_reviewers: false,
      custom_download_reviewer_users: [reviewer.ms_id, other_reviewer.ms_id])
    media = FactoryBot.create(:media, owner: organization.id)
    item = CartItem.new(work_id: media.id)
    allow(sender).to receive(:host_name).and_return('example.org')

    content = sender.cart_item_message_content([item], 'reviewer')

    expect(content).to include(sender.single_user_link(reviewer), sender.single_user_link(other_reviewer), 'multiple reviewers')
  end
end
