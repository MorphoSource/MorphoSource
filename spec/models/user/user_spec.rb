require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user)          { User.create(email: "example@email.com", password: "password") }
  let(:ms1_user)      { User.create(email: "test@test.com", password: "password", ms1_user: true, ms1_password_hash: 'hash') }

  it { should have_many(:cart_items) }
  it { should have_many(:owned_fund_codes) }
  it { should have_many(:fund_code_memberships) }
  it { should have_many(:fund_codes) }
  it { should have_many(:temporary_media_access_links) }

  describe 'after_database_authentication' do
    before do
      ms1_user.after_database_authentication
    end

    it 'converts ms1_user to ms2 user' do
      expect(ms1_user.ms1_user).to be false
      expect(ms1_user.ms1_password_hash).to eq(nil)
    end
  end

  describe 'reset_id_incrementer' do
    describe 'creating a new user' do
      context 'no users exist' do
        before do
          User.create(email: 'newUser@email.com', password: 'password')
        end
        it 'assigns an id of 1' do
          expect(User.find(1)).to be_present
        end
      end
      context 'other users exist' do
        let!(:consoleUser1) { User.create(id: 5, email: 'console1@email.com', password: 'password') }
        let!(:consoleUser2) { User.create(id: 10, email: 'console2@email.com', password: 'password') }
        let!(:consoleUser3) { User.create(id: 15, email: 'console3@email.com', password: 'password') }
        before do
          User.create(email: 'newUser@email.com', password: 'password')
        end
        it 'assigns the next highest id' do
          expect(User.find(16)).to be_present
        end
      end
    end
  end

  describe '#to_s' do
    it 'returns the ms_id' do
      expect(user.to_s).to eq(user.ms_id)
    end
  end


  describe '#display_name and #name' do
    context 'user has a first name and last name' do
      before do
        user.write_attribute(:first_name, 'first')
        user.write_attribute(:last_name, 'last')
        user.write_attribute(:display_name, 'display name')
        user.save
      end
      it 'returns the first and last name' do
        expect(user.display_name).to eq("#{user.first_name} #{user.last_name}")
        expect(user.name).to eq("#{user.first_name} #{user.last_name}")
      end
    end
    context 'user has no first name, no last name, user has a display name' do
      before do
        user.write_attribute(:first_name, nil)
        user.write_attribute(:last_name, nil)
        user.write_attribute(:display_name, 'display name')
        user.save
      end
      it 'returns the display name' do
        expect(user.name).to eq("display name")
      end
    end
    context 'user has no first name, no last name, no display name' do
      before do
        user.write_attribute(:first_name, nil)
        user.write_attribute(:last_name, nil)
        user.write_attribute(:display_name, nil)
        user.save
      end
      it 'returns the ms_id boilerplate' do
        expect(user.name).to eq("User #{user.ms_id.to_s.upcase}")
      end
    end
  end

  describe '#contributor?' do
    context 'user is not a contributor' do
      it 'returns false' do
        expect(user.contributor?).to be(false)
      end
    end
    context 'user is a contributor' do
      before do
        allow(user).to receive(:groups).and_return(['contributor'])
      end
      it 'returns true' do
        expect(user.contributor?).to be(true)
      end
    end
  end

  describe '#batch_submission_contributor?' do
    context 'user is not a batch_submission_contributor' do
      it 'returns false' do
        expect(user.batch_submission_contributor?).to be(false)
      end
    end
    context 'user is a batch_submission_contributor' do
      before do
        allow(user).to receive(:groups).and_return(['batch_submission_contributor'])
      end
      it 'returns true' do
        expect(user.batch_submission_contributor?).to be(true)
      end
    end
  end

  describe '#globus_file_submitter?' do
    context 'user is not a globus_file_submitter' do
      it 'returns false' do
        expect(user.globus_file_submitter?).to be(false)
      end
    end
    context 'user is a globus_file_submitter' do
      before do
        allow(user).to receive(:groups).and_return(['globus_file_submitter'])
      end
      it 'returns true' do
        expect(user.globus_file_submitter?).to be(true)
      end
    end
  end

  describe '#remote_file_submitter?' do
    context 'user is not a remote_file_submitter' do
      it 'returns false' do
        expect(user.remote_file_submitter?).to be(false)
      end
    end
    context 'user is a remote_file_submitter' do
      before do
        allow(user).to receive(:groups).and_return(['remote_file_submitter'])
      end
      it 'returns true' do
        expect(user.remote_file_submitter?).to be(true)
      end
    end
  end

  describe '#can_submit_new_batch_submission?' do
    context 'user cannot submit' do
      it 'returns false when job is working' do
        BackgroundJob.create({ job_id: '456', status: 'working', user_id: user.user_key, created_objects: {} })
        expect(user.can_submit_new_batch_submission?).to be(false)
      end
    end
    context 'user can submit' do
      it 'returns true when never submitted a job' do
        expect(user.can_submit_new_batch_submission?).to be(true)
      end
      it 'returns true when job completed' do
        BackgroundJob.create({ job_id: '456', status: 'completed', user_id: user.user_key, created_objects: {} })
        expect(user.can_submit_new_batch_submission?).to be(true)
      end
    end
  end

  describe '#make_contributor' do
    let(:user) { User.create(email: 'user@email.com', password: 'password') }
    let!(:contributor_group) { Role.create(name: 'contributor') }

    context 'user is not a contributor' do
      it 'adds the user to the contributors group' do
        user.make_contributor
        user.reload
        expect(contributor_group.users).to include(user)
        expect(user.groups).to include('contributor')
      end
      it 'puts a success message' do
        expect { user.make_contributor }.to output("#{user.display_name} is now a contributor\n").to_stdout
      end
    end
    context 'user is a contributor' do
      before do
        allow(user).to receive(:groups).and_return(['contributor'])
      end
      it 'does not add the user to the contributors group' do
        expect { user.make_contributor }.to output("Can't add - #{user.display_name} is already a contributor\n").to_stdout
      end
    end
  end

  describe '#remove_contributor' do
    let!(:contributor_group) { Role.create(name: 'contributor') }
    let!(:user) { User.create(email: 'user@email.com', password: 'password') }
    let!(:another_user) { User.create(email: 'another@email.com', password: 'password') }

    before do
      contributor_group.users += [another_user]
    end

    context 'user is not a contributor' do
      it "can't remove the user from the contributors group" do
        expect { user.remove_contributor }.to output("Can't remove - #{user.display_name} is not a contributor\n").to_stdout
      end
    end
    context 'user is a contributor' do
      before do
        contributor_group.users += [user]
      end
      it 'removes the user from the contributors group' do
        user.remove_contributor
        user.reload
        contributor_group.reload
        expect(contributor_group.users).to include(another_user)
        expect(contributor_group.users).not_to include(user)
        expect(user.groups).not_to include('contributor')
      end
    end
  end

  describe '#registered?' do
    context 'when not registered' do
      before do
        allow(user).to receive(:groups).and_return(['contributor'])
      end
      it 'is false' do
        expect(user.registered?).to be(false)
      end
    end
    context 'when registered' do
      it 'is true' do
        expect(user.registered?).to be(true)
      end
    end
  end

  describe '#collections_managed #collections_with_membership_role_ids' do
    let(:team_a)                { Collection.create(title: ['Team_A'], collection_type_gid: team_collection_type.to_global_id, depositor: user.ms_id) }
    let(:team_b)                { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.to_global_id, depositor: user.ms_id) }
    let(:team_c)                { Collection.create(title: ['Team_C'], collection_type_gid: team_collection_type.to_global_id, depositor: user.ms_id) }
    let(:role1)                 { team_a.managers_group }
    let(:role2)                 { team_b.managers_group }
    let(:role3)                 { team_c.managers_group }
    let(:manager_roles)         { [role1, role2, role3] }
    let(:role4)                 { team_a.editors_group }
    let(:role5)                 { team_b.editors_group }
    let(:editor_roles)          { [role4, role5] }
    let(:role6)                 { team_c.viewers_group }
    let(:viewer_roles)          { [role6] }

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

    it 'returns ids for manager_roles' do
      all_memberships_collection_ids, manager_collection_ids, editor_collection_ids, depositor_collection_ids, downloader_collection_ids, viewer_collection_ids = user.collections_with_membership_role_ids
      expect(manager_collection_ids).to eq(["000200000", "000200001", "000200002"])
    end

    describe 'return ids for editor roles' do
      before do
        allow(user).to receive(:roles).and_return(editor_roles)
      end
      it 'returns ids for the editor_roles' do
        all_memberships_collection_ids, manager_collection_ids, editor_collection_ids, depositor_collection_ids, downloader_collection_ids, viewer_collection_ids = user.collections_with_membership_role_ids
        expect(editor_collection_ids).to eq(["000200000", "000200001"])
      end
    end

    describe 'return ids for viewer roles' do
      before do
        allow(user).to receive(:roles).and_return(viewer_roles)
      end
      it 'returns ids for the viewer_roles' do
        all_memberships_collection_ids, manager_collection_ids, editor_collection_ids, depositor_collection_ids, downloader_collection_ids, viewer_collection_ids = user.collections_with_membership_role_ids
        expect(viewer_collection_ids).to eq(["000200002"])
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

  describe 'fund code methods' do
    let(:creator) { User.create(email: 'admin@email.com', password: 'password') }
    let(:fund_code) { FundCode.new(user: creator, title: 'Fund Code Title', description: 'Fund code description')}
    let(:this_user) { User.create(email: 'user@email.com', password: 'password') }

    before do
      fund_code.save!
    end

    it "can return fund codes where user is manager" do
      fund_code.add_user(this_user, true)
      expect(this_user.managed_fund_codes).to match_array([fund_code])
    end

    it "can return fund codes where user is a member" do
      fund_code.add_user(this_user, false)
      expect(this_user.standard_member_fund_codes).to match_array([fund_code])
    end
  end
end
