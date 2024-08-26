# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModifyCollectionMembershipJob do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'perform' do
    let(:depositor)               { create(:contributor) }
    let(:project1)                { create(:project, depositor: depositor.ms_id ) }
    let(:project2)                { create(:project, depositor: depositor.ms_id ) }
    let(:project3)                { create(:project, depositor: depositor.ms_id ) }
    let(:media)                   { Media.create!(title: ['media']) }


    before do
      project1.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: project1)
      project2.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: project2)
      project3.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: project3)
    end

    it 'adds media to project' do
      described_class.perform_now(
        media_id: media.id, 
        add_to_collection_ids: [project1.id],
      )
      media.reload
      expect(media.member_of_collection_ids).to include(project1.id)
    end

    it 'removes media from project' do
      project1.add_member_objects media
      described_class.perform_now(
        media_id: media.id, 
        remove_from_collection_ids: [project1.id],
      )
      media.reload
      expect(media.member_of_collection_ids).not_to include(project1.id)
    end

    it 'adds media to project while removing media from other project'do
      project1.add_member_objects media
      described_class.perform_now(
        media_id: media.id, 
        add_to_collection_ids: [project2.id],
        remove_from_collection_ids: [project1.id],
      )
      media.reload
      expect(media.member_of_collection_ids).to include(project2.id)
      expect(media.member_of_collection_ids).not_to include(project1.id)
    end

    it 'adds media to two projects while removing media from other project'do
      project1.add_member_objects media
      described_class.perform_now(
        media_id: media.id, 
        add_to_collection_ids: [project2.id, project3.id],
        remove_from_collection_ids: [project1.id],
      )
      media.reload
      expect(media.member_of_collection_ids).to include(project2.id)
      expect(media.member_of_collection_ids).to include(project3.id)
      expect(media.member_of_collection_ids).not_to include(project1.id)
    end

    it 'adds media to project while removing media from two other project'do
      project1.add_member_objects media
      project2.add_member_objects media
      described_class.perform_now(
        media_id: media.id, 
        add_to_collection_ids: [project1.id, project3.id], # also test does nothing when adding to project media already in
        remove_from_collection_ids: [project1.id, project2.id],
      )
      media.reload
      expect(media.member_of_collection_ids).to include(project3.id)
      expect(media.member_of_collection_ids).not_to include(project1.id)
      expect(media.member_of_collection_ids).not_to include(project2.id)
    end

    it 'does nothing if media is added to and removed from collection' do
      described_class.perform_now(
        media_id: media.id, 
        add_to_collection_ids: [project1.id],
        remove_from_collection_ids: [project1.id],
      )
      expect(media.member_of_collection_ids).not_to include(project1.id)
    end
  end
end