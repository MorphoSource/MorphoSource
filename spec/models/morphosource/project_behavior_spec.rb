# frozen_string_literal= true
require 'rails_helper'
RSpec.describe Collection, type: :model do
  let(:depositor)                   { FactoryBot.create(:contributor) }
  let(:media)                       { FactoryBot.create(:media, depositor: depositor.ms_id) }
  let!(:media_list_collection_type) { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::MediaLists::SETTINGS) }
  let!(:project_collection_type)    { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Projects::SETTINGS) }
  let!(:project)                    { Collection.create(title: ["Test Project"],
                                                        depositor: depositor.ms_id,
                                                        collection_type_gid: project_collection_type.to_global_id,
                                                        creator: ["Creator Name 1", "Creator Name 2"],
                                                        contributor: ["Contributor 1", "Contributor 2"],
                                                        description: ["Test Description"],
                                                        based_near: ["Rome, Italy", "London, England"],
                                                        related_url: ["www.google.com", "www.disney.com"],
                                                        representative_id: media.id,
                                                        thumbnail_id: media.id) }

  before do
    ActiveJob::Base.queue_adapter = :test
    project.create_collection_groups
  end

  describe '#fork_to_list' do
    it 'calls copy_as_list with the user' do
      expect(project).to receive(:copy_as_list).with(depositor).and_call_original
      project.fork_to_list(depositor)
    end
    it 'creates permissions for the new list' do
      expect(Morphosource::Collections::PermissionsCreateService).to receive(:create_default).with(collection: instance_of(MediaList))
      project.fork_to_list(depositor)
    end
    it 'copies branding info to the new list' do
      expect(project).to receive(:copy_branding_info_to).with(instance_of(MediaList))
      project.fork_to_list(depositor)
    end
    it 'copies media to the new list' do
      expect(project).to receive(:copy_media_to).with(instance_of(MediaList))
      project.fork_to_list(depositor)
    end
    it 'returns the new list' do
      expect(project.fork_to_list(depositor)).to be_an_instance_of(MediaList)
    end
  end

  describe '#copy_as_list' do
    it 'creates a new MediaList with the correct attributes' do
      list = project.copy_as_list(depositor)
      expect(list).to be_an_instance_of(MediaList)
      expect(list.title).to eq(project.title)
      expect(list.depositor).to eq(depositor.user_key)
      expect(list.creator).to eq([depositor.user_key])
      expect(list.description).to eq(project.description)
      expect(list.based_near).to eq(project.based_near)
      expect(list.related_url).to eq(project.related_url)
      expect(list.representative_id).to eq(project.representative_id)
      expect(list.thumbnail_id).to eq(project.thumbnail_id)
      expect(list.source_collection_ids).to include(project.id)
    end
  end

  describe '#copy_media_to' do
    before do
      media.member_of_collections << project
      media.save!
    end
    it 'enqueues AddCollectionMembersJob with correct parameters' do
      list = project.copy_as_list(depositor)
      expect {
        project.copy_media_to(list)
      }.to have_enqueued_job(AddCollectionMembersJob).with(list.id, [media.id])
    end
  end
end