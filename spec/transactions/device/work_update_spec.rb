# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Transactions::Device::WorkUpdate do
  it 'inherits from Hyrax::Transactions::Transaction' do
    expect(described_class < Hyrax::Transactions::Transaction).to be(true)
  end

  it 'defines the expected default steps' do
    expect(described_class::DEFAULT_STEPS).to eq(
      [
        'device_change_set.set_organization_id',
        'device_change_set.update_organization_access',
        'change_set.apply',
        'work_resource.save_acl',
        'work_resource.update_work_members'
      ]
    )
  end
end
