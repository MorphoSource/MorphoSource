# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveCollectionMembersJob do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'perform' do
    let(:depositor)               { create(:contributor) }
    let(:project)                 { create(:project, depositor: depositor.ms_id ) }
    let(:media)                   { Media.create!(title: ['media']) }
    let(:media2)                  { Media.create!(title: ['media2']) }

    before do
      project.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
      project.add_member_objects media
    end

    context 'with single media ID' do
      it 'removes media from collection' do
        expect(media.member_of_collection_ids).to include(project.id)
        described_class.perform_now(project.id, media.id)
        media.reload
        expect(media.member_of_collection_ids).not_to include(project.id)
      end
    end

    context 'with multiple media IDs' do
      let(:media_ids)               { [media.id, media2.id] }

      it 'launches subsequent jobs, one job per media' do
        expect { 
          described_class.perform_now(project.id, media_ids) 
        }.to change {
          ActiveJob::Base.queue_adapter.enqueued_jobs.count
        }.by media_ids.count
      end
    end
  end
end