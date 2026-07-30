require 'rails_helper'

# Only tests almost-trivial cases
# But full coverage would be complex and SLOW for a service only to be used for a short time
RSpec.describe Morphosource::Organizations::MigrateWorkToCollectionService do
  context 'with no organization' do
    describe '#initialize' do
      it 'throws ActiveFedora::ObjectNotFound if org work does not exist' do
        expect { described_class.new('123456789') }.to raise_error(ActiveFedora::ObjectNotFoundError)
      end
    end
  end

  context 'with empty (no-media no-device) organization' do
    let(:organization_work)  { create(:organization) }

    subject { described_class.new(organization_work.id) }

    describe '#initialize' do
      it 'has appropriate instance variables' do
        expect(subject.organization_work_id).to eq(organization_work.id)
        expect(subject.organization_work.id).to eq(organization_work.id)
        expect(subject.organization_team).to eq(nil)
        expect(subject.organization_team_id).to eq(nil)
        expect(subject.organization_collection).to eq(nil)
        expect(subject.organization_collection_id).to eq(nil)
        expect(subject.all_media_ids).to eq([])
        expect(subject.organization_metadata[:title]&.first).to eq(organization_work.title.first)
      end
    end

    describe '#migrate' do
      before do
        subject.migrate
      end

      it 'creates organization collection' do
        expect(subject.organization_collection).to be_present
        expect(subject.organization_collection_id).to eq(subject.organization_collection.id)
        expect(subject.organization_collection.title&.first).to eq(organization_work.title.first)
        expect(subject.organization_collection.legacy_organization_work_id).to eq(organization_work.id)
      end
    end

    context 'when the legacy organization has a management date' do
      let(:legacy_date_managed) { Date.new(2020, 1, 2) }

      before do
        allow(organization_work).to receive(:date_managed).and_return(legacy_date_managed)
      end

      context 'with a non-admin data manager' do
        let(:data_manager) { create(:contributor) }
        let(:organization_work) { create(:organization, data_manager: [data_manager.user_key]) }

        it 'preserves the date when assigning the manager' do
          subject.migrate

          expect(subject.organization_collection.managers).to include(data_manager)
          expect(subject.organization_collection.date_managed).to eq(legacy_date_managed)
        end
      end

      context 'without a non-admin manager' do
        let(:default_manager) { create(:admin) }

        before do
          allow(Morphosource).to receive(:default_organization_manager).and_return(default_manager.ms_id)
        end

        it 'does not carry the date onto an admin-managed collection' do
          subject.migrate

          expect(subject.organization_collection).not_to be_managed_by_non_admin
          expect(subject.organization_collection.date_managed).to be_nil
          expect(subject.is_migrated?).to eq(true)
        end
      end
    end

    # The batch user deposits the collection, so with no configured default it is
    # the manager seeded at creation. Removing it as part of copying the team over
    # is only safe once the team has supplied a manager of its own.
    context 'with a legacy team that has no managers' do
      let(:organization_team)  { create(:team) }
      let(:organization_work)  { create(:organization, team_id: [organization_team.id]) }

      before do
        # The team factory stubs Collection.find for its own id, so the organization
        # collection's own lookups need a passthrough default.
        allow(Collection).to receive(:find).and_call_original
        allow(Morphosource).to receive(:default_organization_manager).and_return(nil)
      end

      it 'keeps the seeded manager rather than migrating an unmanaged organization' do
        subject.migrate

        expect(subject.organization_collection.managers).to eq([User.batch_user])
        expect(subject.is_migrated?).to eq(true)
      end
    end

    describe '#is_migrated?' do
      before do
        subject.migrate
      end

      it 'creates organization collection' do
        expect(subject.is_migrated?).to eq(true)
      end
    end

    describe '#complete_migration' do
      before do
        subject.migrate
        subject.complete_migration
      end

      it 'destroys organization work but leaves organization collection' do
        expect(subject.is_migrated?).to eq(true)
        expect(subject.organization_collection).to be_present
        expect(subject.organization_collection.title&.first).to eq(organization_work.title.first)
        expect(subject.organization_collection.legacy_organization_work_id).to eq(organization_work.id)

        # test org work deletion in slightly roundabout way due to factory mocked methods on .find
        expect { subject.organization_work.reload }.to raise_error(ActiveFedora::ObjectNotFoundError)
      end
    end
  end
end
