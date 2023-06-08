# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MediaList, type: :model do
  let(:user)                        { FactoryBot.create(:user) }
  let(:media_list)                  { FactoryBot.create(:media_list, depositor: user.ms_id) }

  let(:media)                       { FactoryBot.create(:media, depositor: user.ms_id) }
  let(:media2)                      { FactoryBot.create(:media, depositor: user.ms_id) }
  let(:media3)                      { FactoryBot.create(:media, depositor: user.ms_id) }

  let(:works)                       { [media, media2, media3] }
  let(:work_ids)                    { [media.id, media2.id, media3.id] }

  describe 'DEFAULT_GROUP_ROLES' do
    it { expect(described_class::DEFAULT_GROUP_ROLES).to match_array(['managers', 'viewers']) }
  end

  describe 'collection_type' do
    it { expect(described_class.collection_type).to eq(media_list_collection_type) }
    it { expect(subject.collection_type).to eq(media_list_collection_type) }
  end

  describe 'presenter_class' do
    it { expect(subject.presenter_class).to eq(Morphosource::Collections::MediaListPresenter) }
  end

  describe 'list?' do
    it { expect(subject.list?).to be(true) }
  end

  describe 'type_assigns_groups?' do
    it { expect(subject.type_assigns_groups?).to be(true) }
  end

  describe 'human_readable_type' do
    it { expect(subject.human_readable_type).to eq("Media List") }
  end

  describe 'groups' do
    let(:managers_group_name) { media_list.id + "_managers" }
    let(:viewers_group_name)  { media_list.id + "_viewers" }

    describe 'user_groups' do
      it 'is managers and viewers' do
        expect(media_list.user_groups.map(&:name)).to match_array([managers_group_name, viewers_group_name])
      end
    end

    describe 'group_members' do
      let(:manager) { FactoryBot.create(:user) }
      let(:viewer)  { FactoryBot.create(:user) }
      before do
        media_list.managers_group.users << [manager]
        media_list.viewers_group.users << [viewer]
        media_list.user_groups.each(&:save)
      end
      it 'is managers and viewers' do
        expect(media_list.group_members).to match_array([user, manager, viewer])
      end
    end
  end

  describe '#add_member_objects' do
    it 'adds works to the collection' do
      media_list.add_member_objects(work_ids)
      expect(media_list.member_objects).to match_array(works)
    end

    it 'does not apply additional permissions to the works' do
      media_list.add_member_objects(work_ids)
      works.each do |work|
        work.reload
        expect(work.edit_groups).not_to include(media_list.managers_group.name, media_list.viewers_group.name)
        expect(work.download_groups).not_to include(media_list.managers_group.name, media_list.viewers_group.name)
        expect(work.read_groups).not_to include(media_list.managers_group.name, media_list.viewers_group.name)
      end
    end

    it 'does not call inherit permissions' do
      works.each do |work|
        expect(InheritPermissionsJob).not_to receive(:perform_later).with(work)
      end
      media_list.add_member_objects(work_ids)
    end
  end

  describe '#remove_member_objects' do
    it 'removes the member objects' do
      media_list.add_member_objects(work_ids)
      expect(media_list.member_objects).to match_array(works)

      media_list.remove_member_objects(work_ids)
      expect(media_list.member_objects).to match_array([])
    end

    it 'does not call inherit permissions' do
      works.each do |work|
        expect(InheritPermissionsJob).not_to receive(:perform_later).with(work)
      end
      media_list.remove_member_objects(work_ids)
    end
  end
end
