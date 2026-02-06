# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Transactions::Device::WorkDestroy do
  it 'inherits from Hyrax::Transactions::Transaction' do
    expect(described_class < Hyrax::Transactions::Transaction).to be(true)
  end

  it 'defines the expected default steps' do
    expect(described_class::DEFAULT_STEPS).to eq(
      [
        'device_work_resource.delete_ark_if_reserved',
        'work_resource.delete_acl',
        'work_resource.delete'
      ]
    )
  end
end
