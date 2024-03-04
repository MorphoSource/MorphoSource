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

  describe 'remove_deleted_transfers' do
    let(:media1)  { Media.create(title: ['media1']) }
    let(:media2)  { Media.create(title: ['media2']) }
    let(:media3)  { Media.create(title: ['media3']) }
    let(:media)   { [media1, media2, media3] }

    let!(:contributor_role)  { Role.create(name: "contributor") }

    before do
      user6.make_contributor
      media.each do |m|
        ProxyDepositRequest.create(
        work_id: m.id, sending_user_id: user5.id, receiving_user_id: user6.id, status: "pending", sender_comment: "test")
      end
    end

    context 'there are no transfers' do
      it 'returns a blank array' do
        expect(described_class.remove_deleted_transfers([])).to match_array([])
      end
    end

    context 'all request media have solr docs' do
      it 'returns all requests' do
        expect(described_class.remove_deleted_transfers(ProxyDepositRequest.all)).to match_array(ProxyDepositRequest.all)
      end
    end

    context 'some request media are missing' do
      let(:deleted_media) { Media.create(title: ['deleted media']) }
      before do
        ProxyDepositRequest.create(
          work_id: deleted_media.id, sending_user_id: user5.id, receiving_user_id: user6.id, status: "pending", sender_comment: "test")
        deleted_media.destroy!
      end
      it 'returns only the transfer requests for existing media' do
        expect(ProxyDepositRequest.all.map(&:work_id)).to match_array([media1.id, media2.id, media3.id, deleted_media.id])
        expect(described_class.remove_deleted_transfers(ProxyDepositRequest.all).map(&:work_id)).to match_array([media1.id, media2.id, media3.id])
      end
    end
  end

  describe 'incoming_for' do
    let!(:receiving_user) { FactoryBot.create(:contributor) }
    let(:work)            { FactoryBot.create(:media) }
    let(:organization)    { FactoryBot.create(:organization_collection, depositor: user6.ms_id) }
    let!(:proxy_deposit_request) {
      ProxyDepositRequest.create(
      work_id: work.id, sending_user_id: user5.id, receiving_user_id: organization.id, status: "pending", sender_comment: "test")
    }

    context 'receiving_user is the user' do
      before do
        proxy_deposit_request.receiving_user_id = receiving_user.id
        proxy_deposit_request.save!
      end
      it 'returns the request' do
        expect(ProxyDepositRequest.incoming_for(user: receiving_user, number_of_days: 'all')).to match_array([proxy_deposit_request])
      end
    end

    context 'receiving_user is an organization' do
      let(:work2)           { FactoryBot.create(:media) }
      let(:work3)           { FactoryBot.create(:media) }
      let(:organization2)   { FactoryBot.create(:organization_collection, depositor: user6.ms_id) }
      let(:organization3)   { FactoryBot.create(:organization_collection, depositor: user6.ms_id) }
      let(:proxy_deposit_request2) {
        ProxyDepositRequest.create(
        work_id: work2.id, sending_user_id: user5.id, receiving_user_id: organization2.id, status: "pending", sender_comment: "test")
      }
      let(:proxy_deposit_request3) {
        ProxyDepositRequest.create(
        work_id: work3.id, sending_user_id: user5.id, receiving_user_id: organization3.id, status: "pending", sender_comment: "test")
      }

      context 'user is an organization manager' do
        before do
          allow(receiving_user).to receive(:groups).and_return(["#{organization.id}_managers"])
        end
        it 'returns the request for organization managers' do
          expect(ProxyDepositRequest.incoming_for(user: receiving_user, number_of_days: 'all')).to match_array([proxy_deposit_request])
        end
      end

      context 'user is not an organization manager' do
        it 'does not return the request' do
          expect(ProxyDepositRequest.incoming_for(user: receiving_user, number_of_days: 'all')).to match_array([])
        end
      end
      context 'user manages multiple organizations' do
        before do
          [proxy_deposit_request2, proxy_deposit_request3].each(&:touch)
          allow(receiving_user).to receive(:groups).and_return(["#{organization.id}_managers", "#{organization2.id}_managers", "#{organization3.id}_managers"])
        end

        it 'returns the requests for organization managers' do
          expect(ProxyDepositRequest.incoming_for(user: receiving_user, number_of_days: 'all')).to match_array([proxy_deposit_request, proxy_deposit_request2, proxy_deposit_request3])
        end

        context 'user manages multiple organizations and individual media' do
          let(:work4) { FactoryBot.create(:media) }
          let(:work5) { FactoryBot.create(:media) }

          let!(:proxy_deposit_request4) { ProxyDepositRequest.create(work_id: work4.id, sending_user_id: user5.id, receiving_user_id: receiving_user.id, status: "pending", sender_comment: "test") }
          let!(:proxy_deposit_request5) { ProxyDepositRequest.create(work_id: work5.id, sending_user_id: user5.id, receiving_user_id: receiving_user.id, status: "pending", sender_comment: "test") }

          it 'returns the request for organization managers and individual requests' do
            expect(ProxyDepositRequest.incoming_for(user: receiving_user, number_of_days: 'all')).to match_array([proxy_deposit_request, proxy_deposit_request2, proxy_deposit_request3, proxy_deposit_request4, proxy_deposit_request5])
          end
        end
      end
    end
  end
end
