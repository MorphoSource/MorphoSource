# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Transactions::Device::WorkCreate do
  it 'inherits from Hyrax::Transactions::Transaction' do
    expect(described_class < Hyrax::Transactions::Transaction).to be(true)
  end

  it 'defines the expected default steps' do
    expect(described_class::DEFAULT_STEPS).to eq(
      [
        'device_change_set.assign_id',
        'device_change_set.set_organization_id',
        'device_change_set.update_organization_access',
        'change_set.set_default_admin_set',
        'change_set.ensure_admin_set',
        'change_set.set_user_as_depositor',
        'change_set.apply',
        'work_resource.apply_permission_template',
        'work_resource.save_acl',
        'work_resource.change_depositor',
        'device_work_resource.mint_ark'
      ]
    )
  end
end
