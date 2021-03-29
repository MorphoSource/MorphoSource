require 'rails_helper'

RSpec.describe FundCodeMediaAssociation do 
  it { should belong_to(:fund_code) }

  describe "instance" do
    let(:user) { User.create(email: 'user@email.com', password: 'password') }
    let(:fund_code) { FundCode.new(title: 'Test Title', description: 'Test Description', user: user) }

    subject { described_class.new }

    it "is valid with valid attributes" do
      subject.fund_code = fund_code
      subject.media = "123456789"
      subject.active = true
      expect(subject).to be_valid
    end
  end
end
