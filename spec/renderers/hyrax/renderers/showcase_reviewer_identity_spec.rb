require 'rails_helper'

RSpec.describe Hyrax::Renderers::ShowcaseUserLinkAttributeRenderer do
  it 'links organization reviewer tokens to the organization using indexed display data' do
    organization = FactoryBot.create(:organization_collection, title: ['Reviewing organization'])
    expect(OrganizationCollection).not_to receive(:find)
    expect(User).not_to receive(:find_by_user_key)
    html = described_class.new(:download_reviewers, ["org_collection:#{organization.id}"]).render
    expect(html).to include("/organizations/#{organization.id}", 'Reviewing organization')
  end
end
