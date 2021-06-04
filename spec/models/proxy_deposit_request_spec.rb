require 'rails_helper'

RSpec.describe ProxyDepositRequest do
  let!(:user5)          { User.create(id: '5', email: "purple@email.com", password: "password", display_name: "Mickey Mouse") }
  let!(:user6)          { User.create(id: '6', email: "blue@email.com", password: "password", display_name: "Donald Duck") }

  describe "instance" do
    subject { described_class.new }

    let!(:proxy_deposit_request) {
      ProxyDepositRequest.create(
        work_id: "000200122", sending_user_id: user5.id, receiving_user_id: user6.id, status: "pending", sender_comment: "test")
    }

    context 'transfer_to_should_be_a_contributor' do
      it 'is not valid' do
        subject.sending_user = user5
        subject.receiving_user = user6
        expect(subject).to_not be_valid
        expect(subject.errors[:transfer_to]).to eq(["must have contributor access"])
      end
    end
  end

end
