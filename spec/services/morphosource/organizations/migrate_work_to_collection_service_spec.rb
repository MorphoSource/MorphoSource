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