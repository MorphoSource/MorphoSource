require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user)          { User.create(email: "example@email.com", password: "password") }
  let(:ms1_user)      { User.create(email: "test@test.com", password: "password", ms1_user: true, ms1_password_hash: 'hash') }

  describe 'after_database_authentication' do
    before do 
      ms1_user.after_database_authentication
    end

    it 'converts ms1_user to ms2 user' do
      expect(ms1_user.ms1_user).to be false
      expect(ms1_user.ms1_password_hash).to eq(nil)
    end
  end

  describe '#to_s' do
    it 'returns the ms_id' do
      expect(user.to_s).to eq(user.ms_id)
    end
  end

  describe '#name' do
    context 'user has a display name' do
      before do
        user.display_name = 'display name'
        user.save
      end
      it 'returns the display name' do
        expect(user.name).to eq(user.display_name)
      end
    end
    context 'user does not have a display name' do
      before do
        user.display_name = nil
        user.save
      end
      it 'returns the email address' do
        expect(user.name).to eq(user.email)
      end
    end

    describe '#collections_managed' do
      let(:team_collection_type)  { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
      let(:team_a)                { Collection.create(title: ['Team_A'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
      let(:team_b)                { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
      let(:team_c)                { Collection.create(title: ['Team_C'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
      let(:role1)                 { team_a.managers_group }
      let(:role2)                 { team_b.managers_group }
      let(:role3)                 { team_c.managers_group }
      let(:manager_roles)         { [role1, role2, role3] }

      before do
        team_a.create_collection_groups
        team_b.create_collection_groups
        team_c.create_collection_groups
        allow(user).to receive(:roles).and_return(manager_roles)
        allow(Collection).to receive(:where).with(id: [team_a.id, team_b.id, team_c.id]).and_return([team_a, team_b, team_c])
      end

      it 'returns all collections where user belongs to default _manager role' do
        expect(user.collections_managed).to match_array([team_a, team_b, team_c])
      end
    end
  end

  describe '#check_ms_id' do
    let(:new_user1) { User.new(email: "testemail@email.com", password: "password")}
    let(:old_ms_id) { "abc123" }
    let(:new_user2) { User.new(email: "another@email.com", password: "password", ms_id: old_ms_id)}
    before do
      [new_user1, new_user2].each(&:save)
      [new_user1, new_user2].each(&:reload)
    end
    it 'assigns an ms_id to new users without one' do
      expect(new_user1.ms_id).to_not be(nil)
    end
    it 'does not assign an ms_id to users who already have one' do
      expect(new_user2.ms_id).to eq(old_ms_id)
    end
  end
end
