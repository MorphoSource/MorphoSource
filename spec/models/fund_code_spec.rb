require 'rails_helper'

RSpec.describe FundCode do
  it { should belong_to(:user) }
  it { should have_many(:fund_code_memberships) }
  it { should have_many(:members) }
  it { should have_many(:fund_code_media_associations) }

  describe "instance" do
    let(:creator) { User.create(email: 'admin@email.com', password: 'password')}
    let(:manager) { User.create(email: 'manager@email.com', password: 'password') }
    let(:member) { User.create(email: 'member@email.com', password: 'password') }
    let(:other_user) { User.create(email: 'other@email.com', password: 'password') }

    subject { described_class.new }

    before do
      subject.user = creator
      subject.add_user(manager, true)
      subject.add_user(member, false)
      subject.save!
    end

    it "is valid with valid attributes" do
      subject.title = 'Test title'
      subject.description = 'Test description'
      expect(subject).to be_valid
    end

    it "can have users added" do
      subject.add_user(other_user, false)
      expect(subject.members).to match_array([manager, member, other_user])
      expect(subject.managers).to match_array([manager])
      expect(subject.standard_members).to match_array([member, other_user])
    end

    it "can have users deleted" do
      subject.delete_user(manager)
      expect(subject.members).to match_array([member])
      expect(subject.managers).to match_array([])
    end

    it "can promote standard member users to managers" do
      subject.make_user_manager(member)
      expect(subject.managers).to match_array([manager, member])
      expect(subject.standard_members).to match_array([])
    end

    it "can demote manager users to standard members" do
      subject.make_user_standard(manager)
      expect(subject.managers).to match_array([])
      expect(subject.standard_members).to match_array([manager, member])
    end
  end
end
