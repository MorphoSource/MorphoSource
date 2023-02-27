# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MediaList, type: :model do
  let!(:media_list_collection_type)  { Hyrax::CollectionType.create(title: 'List', machine_id: 'media_list') }
  let(:user)                        { User.create(email: 'email@email.com', password: 'password') }
  let(:media_list)                  { MediaList.create(title: ['media list'], collection_type_gid: media_list_collection_type.gid, depositor: user.ms_id) }

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
      let(:manager) { User.create(email: 'manager@email.com', password: 'password') }
      let(:viewer)  { User.create(email: 'viewer@email.com', password: 'password') }
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

end
