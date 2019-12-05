require 'rails_helper'
RSpec.describe Collection, type: :model do

  let(:team_collection_type) { Hyrax::CollectionType.create(title: "Team", machine_id: 88) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: "Project", machine_id: 77) }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: "Another", machine_id: 99) }
  let(:user) { User.create(email: "email@email.com", password: "password", ms_id: "abc123") }

  describe '#create_collection_groups' do
    before do
      allow(User).to receive(:find_by).with(ms_id: user.ms_id).and_return(user)
    end
    it 'is called on create' do
      @collection = Collection.new(title: ['Team_A'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id)
      expect(@collection).to receive(:create_collection_groups)
      @collection.save
    end

    describe 'a user creates a new team' do
      it 'creates manager, depositor, and viewer groups' do
        expect{ Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id)
        }.to change{ Role.count }.by(3)
      end
      it 'assigns them names with the collection id' do
        @collection = Collection.create(title: ['Team_C'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id)

        group_names = Role.all.map(&:name)
        Collection::DEFAULT_GROUP_ROLES.each do |role|
          expect(group_names).to include("#{@collection.id}_#{role}")
        end
      end
    end

    describe 'a user creates a new project' do
      it 'creates manager, depositor, and viewer groups' do
        expect{ Collection.create(title: ['Project_A'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id)
        }.to change{ Role.count }.by(3)
      end
      it 'assigns them names with the collection id' do
        @collection = Collection.create(title: ['Team_C'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id)

        group_names = Role.all.map(&:name)
        Collection::DEFAULT_GROUP_ROLES.each do |role|
          expect(group_names).to include("#{@collection.id}_#{role}")
        end
      end
    end

    describe 'a user creates another type of collection' do
      it 'does not create collection groups' do
        expect{ Collection.create(title: ['Another'], collection_type_gid: another_collection_type.gid, depositor: user.ms_id)
        }.to_not change{ Role.count }
      end
    end

    describe 'user groups' do
      let(:collection) { Collection.create(title: ['collection title'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
      let(:user1) { User.new(email: 'email1@email.com', password: 'password') }
      let(:user2) { User.new(email: 'email2@email.com', password: 'password') }
      let(:user3) { User.new(email: 'email3@email.com', password: 'password') }
      let(:user4) { User.new(email: 'email4@email.com', password: 'password') }
      let(:user5) { User.new(email: 'email5@email.com', password: 'password') }
      let(:user6) { User.new(email: 'email6@email.com', password: 'password') }
      let(:all_users) { [user, user1, user2, user3, user4, user5, user6] }

      before do
        collection.managers_group.users << user1 << user2
        collection.depositors_group.users << user3 << user4
        collection.viewers_group.users << user5 << user6
        collection.user_groups.each(&:save)
      end

      describe '#managers, #depositors, #viewers' do
        it 'returns users for each of the different roles' do
          expect(collection.managers).to match_array([user,user1,user2])
          expect(collection.depositors).to match_array([user3,user4])
          expect(collection.viewers).to match_array([user5,user6])
        end
      end

      describe '#group_members' do
        it 'returns all users with a collection role' do
          expect(collection.group_members).to match_array(all_users)
        end
      end
    end
  end
end
