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

  # Integration test: verifies that organization edit_groups set by
  # UpdateOrganizationAccess on the change_set's model (before change_set.apply)
  # survive change_set.sync, persister.save, and save_acl, and are ultimately
  # readable on the reloaded resource.
  #
  # This matters because UpdateOrganizationAccess writes directly to
  # resource.edit_groups (via the permission_manager) before change_set.apply
  # syncs the change_set onto the model. If sync or save clobbered those
  # changes, org groups would be silently lost.
  describe 'organization edit_groups persistence through the transaction pipeline' do
    # Run just the steps that follow set_organization_id; we set organization_id
    # on the change_set directly to avoid needing controller/request params.
    subject(:transaction) do
      described_class.new(steps: [
        'device_change_set.update_organization_access',
        'change_set.apply',
        'work_resource.save_acl',
        'work_resource.update_work_members'
      ])
    end

    let(:old_org_id) { 'old-org-123' }
    let(:new_org_id) { 'new-org-456' }
    let!(:depositor) { User.create!(email: 'device_update_spec@example.com', password: 'password') }

    # Use with_index: false so the factory doesn't try to resolve the fake org
    # ID via ActiveFedora during Solr indexing. We stub #organization on any
    # DeviceResource instance for the same reason during transaction saves.
    before { allow_any_instance_of(DeviceResource).to receive(:organization).and_return(nil) } # rubocop:disable RSpec/AnyInstance

    let!(:device) do
      FactoryBot.valkyrie_create(:device_resource, organization_id: [old_org_id],
                                                    depositor: depositor.user_key,
                                                    with_index: false)
    end

    context 'when changing from one organization to another' do
      it 'persists the new organization groups and removes the old ones' do
        change_set = Hyrax::ChangeSet.for(device)
        change_set.organization_id = [new_org_id]

        result = transaction.call(change_set)
        expect(result).to be_success

        reloaded = Hyrax.query_service.find_by(id: device.id)
        edit_groups = reloaded.permission_manager.edit_groups.to_a

        expect(edit_groups).to include("#{new_org_id}_managers", "#{new_org_id}_editors")
        expect(edit_groups).not_to include("#{old_org_id}_managers", "#{old_org_id}_editors")
      end
    end

    context 'when assigning an organization for the first time' do
      let!(:device) { FactoryBot.valkyrie_create(:device_resource, depositor: depositor.user_key, with_index: false) }

      it 'persists the new organization groups' do
        change_set = Hyrax::ChangeSet.for(device)
        change_set.organization_id = [new_org_id]

        result = transaction.call(change_set)
        expect(result).to be_success

        reloaded = Hyrax.query_service.find_by(id: device.id)
        edit_groups = reloaded.permission_manager.edit_groups.to_a

        expect(edit_groups).to include("#{new_org_id}_managers", "#{new_org_id}_editors")
      end
    end

    context 'when clearing the organization' do
      it 'removes old organization groups' do
        # pre-seed edit_groups on the persisted ACL so there is something to remove
        device.permission_manager.edit_groups += ["#{old_org_id}_managers", "#{old_org_id}_editors"]
        device.permission_manager.acl.save

        change_set = Hyrax::ChangeSet.for(Hyrax.query_service.find_by(id: device.id))
        change_set.organization_id = []

        result = transaction.call(change_set)
        expect(result).to be_success

        reloaded = Hyrax.query_service.find_by(id: device.id)
        edit_groups = reloaded.permission_manager.edit_groups.to_a

        expect(edit_groups).not_to include("#{old_org_id}_managers", "#{old_org_id}_editors")
      end
    end
  end
end
