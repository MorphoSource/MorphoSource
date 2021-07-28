require 'rails_helper'

RSpec.describe FundCodeCharge do
  it { should belong_to(:fund_code) }

  describe "instance" do
    let(:user) { User.create(email: 'user@email.com', password: 'password') }
    let(:fund_code) { FundCode.new(title: 'Test Title', identifier: '1234', description: 'Test Description', total: 100.to_d, user: user) }

    subject { described_class.new }

    before do
      fund_code.save!
      subject.fund_code = fund_code
      subject.save!
    end

    it "is valid with valid attributes" do
      subject.description = 'Test description'
      expect(subject).to be_valid
    end

    it "has remaining amount updated based on fund code total " do
      subject.amount = 25.to_d
      subject.save!
      expect(subject.fund_code_remaining).to eq(75.to_d)
    end

    it "can export attributes as hash" do
      subject.description = 'Test description'
      subject.fund_code = fund_code
      subject.amount = 25.to_d
      subject.save!

      expect(subject.to_h(:csv)).to include(
        description: 'Test description',
        amount: '25.00',
        fund_code: '1234',
        morphosource_fund_code_title: 'Test Title',
        morphosource_funds_remaining: '75.00'
      )
    end
  end
end
