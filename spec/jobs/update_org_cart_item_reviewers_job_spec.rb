# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateOrgCartItemReviewersJob do
  subject(:job) { described_class.new }

  let(:org_id) { 'organization-id' }
  let(:org) { instance_double(OrganizationCollection) }

  it 'loads the organization from the serializable id argument' do
    allow(OrganizationCollection).to receive(:find).with(org_id).and_return(org)
    allow(job).to receive(:affected_media_ids).with(org).and_return([])

    job.perform(org_id)

    expect(OrganizationCollection).to have_received(:find).with(org_id)
  end
end
