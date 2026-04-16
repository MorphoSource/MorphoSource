require 'rails_helper'

RSpec.describe FundCode do
  it { should belong_to(:user) }
  it { should have_many(:fund_code_memberships) }
  it { should have_many(:members) }
  it { should have_many(:fund_code_media_associations) }
  it { should have_many(:charges) }
  it { should have_one(:data_allocation) }

  describe "data allocation" do
    let(:creator) { User.create!(email: 'alloc@email.com', password: 'password') }

    context "on creation" do
      it "creates a data allocation automatically" do
        fc = FundCode.create!(user: creator, storage_total_gb: 50)
        expect(fc.data_allocation).to be_present
        expect(fc.data_allocation.allocation_type).to eq("fund_code")
        expect(fc.data_allocation.storage_total_gb).to eq(50)
      end

      it "does not create a duplicate if one already exists" do
        fc = FundCode.create!(user: creator)
        expect { fc.run_callbacks(:create) }.not_to change { DataAllocation.where(fund_code: fc).count }
      end

      it "creates a data allocation with the default storage_total_gb when fund code has none" do
        fc = FundCode.create!(user: creator)
        expect(fc.data_allocation.storage_total_gb).to eq(Hyrax.config.default_storage_total_gb)
      end
    end

    context "on update" do
      let(:fund_code) { FundCode.create!(user: creator, storage_total_gb: 50) }

      it "syncs storage_total_gb to data allocation when changed" do
        fund_code.update!(storage_total_gb: 100)
        expect(fund_code.data_allocation.reload.storage_total_gb).to eq(100)
      end

      it "does not update data allocation when other fields change" do
        fund_code.update!(title: "New Title")
        expect(fund_code.data_allocation.reload.storage_total_gb).to eq(50)
      end
    end
  end

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
