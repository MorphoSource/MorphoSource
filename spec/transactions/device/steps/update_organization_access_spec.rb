# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Transactions::Device::Steps::UpdateOrganizationAccess do
  subject(:step) { described_class.new }

  describe '#call' do
    let(:previous_org) { [] }
    let(:new_org) { [] }
    let(:resource) { instance_double('DeviceResource', organization_id: previous_org, edit_groups: current_groups) }
    let(:change_set) { instance_double('ChangeSet', model: resource, organization_id: new_org) }
    let(:current_groups) { [] }

    context 'when changing organizations' do
      let(:previous_org) { ['old-org'] }
      let(:new_org) { ['new-org'] }

      it 'replaces old organization groups with new ones' do
        allow(resource).to receive(:edit_groups=)

        result = step.call(change_set)

        expect(result).to be_success
        expect(resource).to have_received(:edit_groups=).with(
          match_array(['new-org_managers', 'new-org_editors'])
        )
      end
    end

    context 'when new organization is blank' do
      let(:previous_org) { ['old-org'] }
      let(:new_org) { [nil] }
      let(:current_groups) { ['old-org_managers', 'old-org_editors'] }

      it 'removes old organization groups' do
        allow(resource).to receive(:edit_groups=)

        result = step.call(change_set)

        expect(result).to be_success
        expect(resource).to have_received(:edit_groups=).with([])
      end
    end

    context 'when previous and new organizations are the same' do
      let(:previous_org) { ['org-1'] }
      let(:new_org) { ['org-1'] }
      let(:current_groups) { ['org-1_managers', 'org-1_editors', 'extra'] }

      it 'keeps existing organization groups' do
        allow(resource).to receive(:edit_groups=)

        result = step.call(change_set)

        expect(result).to be_success
        expect(resource).to have_received(:edit_groups=).with(
          match_array(['org-1_managers', 'org-1_editors', 'extra'])
        )
      end
    end

    it 'returns failure when an error occurs' do
      previous_org = []
      new_org = []
      allow(resource).to receive(:organization_id).and_return(previous_org)
      allow(change_set).to receive(:organization_id).and_return(new_org)
      allow(change_set).to receive(:model).and_raise('boom')

      result = step.call(change_set)

      expect(result).to be_failure
      expect(result.failure[0]).to eq(:update_organization_access_failed)
      expect(result.failure[1]).to eq(change_set)
      expect(result.failure[2]).to eq('boom')
    end
  end
end
