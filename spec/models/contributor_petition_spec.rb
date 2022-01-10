require 'rails_helper'

RSpec.describe ContributorPetition do
  it { should belong_to(:user) }

  describe "instance" do
    let(:user) { User.create(email: 'user@email.com', password: 'password') }
    let(:petition_attrs) {
      {
        user: user,
        reason: 'Application reason',
        user_affiliation: 'Test Org',
        user_department: 'Test Dept',
        user_demographics: ['Student (Post-Graduate)', 'Faculty (Grades K-7)'],
        user_demographics_other: 'Volunteer',
        user_advisor: 'Adviser name, affiliation, and email',
        contribution_amount: '1 GB',
        terms_agree: true,
        decision_required: true
      }
    }

    subject { described_class.new(petition_attrs) }

    before do
      subject.save!
    end

    it "is valid with valid attributes" do
      subject.reason = 'New application reason'
      expect(subject).to be_valid
    end

    it "is associated with the correct user" do
      expect(subject.user).to eq(user)
    end
  end
end