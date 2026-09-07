# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Transactions::ImagingEvent::WorkCreate do
  it 'inherits from Hyrax::Transactions::Transaction' do
    expect(described_class < Hyrax::Transactions::Transaction).to be(true)
  end

  it 'defines the expected default steps' do
    expect(described_class::DEFAULT_STEPS).to eq(
      [
        'change_set.assign_id',
        'change_set.set_default_admin_set',
        'change_set.ensure_admin_set',
        'change_set.set_user_as_depositor',
        'imaging_event_change_set.set_title',
        'imaging_event_change_set.apply_date_filter',
        'imaging_event_change_set.apply_controlled_values',
        'change_set.apply',
        'work_resource.apply_permission_template',
        'work_resource.save_acl',
        'work_resource.change_depositor'
      ]
    )
  end

  describe '#with_step_args' do
    it 'ignores legacy parent/file-set args without raising' do
      transaction = described_class.new

      expect {
        transaction.with_step_args(
          'work_resource.add_to_parent' => {},
          'work_resource.add_file_sets' => {},
          'change_set.set_user_as_depositor' => { user: nil }
        )
      }.not_to raise_error
    end
  end
end
