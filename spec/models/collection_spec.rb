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
  end
end
